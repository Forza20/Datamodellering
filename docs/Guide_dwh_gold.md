# Guide: dwh_gold – fra CSV til Power BI-dashboard

Trin-for-trin-guide til datavarehuset `dwh_gold`: medallion-lagene i Supabase (bronze → silver → gold),
Power BI-modellen i PBIP/TMDL og dashboardet "Salgsoverblik".

## 1. Overblik

| Lag | Hvor | Indhold |
|---|---|---|
| Bronze | Supabase, skema `bronze` | Rå CSV-data, 1:1 med kildefilerne (6 tabeller) |
| Silver | Supabase, skema `silver` | Renset og ensrettet data (`silver.load_silver()`) |
| Gold | Supabase, skema `gold` | Stjerneskema: `dim_customers`, `dim_products`, `fact_sales` (`gold.load_gold()`) |
| Model | `output/dwh_gold/dwh_gold.SemanticModel` | Power BI-model i TMDL, inkl. `dim_date` og `_Measures` |
| Rapport | `output/dwh_gold/dwh_gold.Report` | PBIR-rapport med siden "Dashboard" |

Diagram over gold-laget: `diagrams/dwh_gold.dbml` (indsæt på https://dbdiagram.io/d).

### Stjerneskema

- **Grain i `fact_sales`:** én række pr. ordrelinje (ordrenummer + produkt).
- **Dimensioner:** `dim_customers` (kunde, land, køn, civilstand), `dim_products` (produkt, kategori,
  underkategori, kostpris – kun aktive produkter), `dim_date` (kalender genereret i Power Query).
- **Relationer (mange-til-én):**
  - `fact_sales[customer_key]` → `dim_customers[customer_key]`
  - `fact_sales[product_key]` → `dim_products[product_key]`
  - `fact_sales[order_date]` → `dim_date[date_key]` (aktiv)
  - `fact_sales[shipping_date]` og `fact_sales[due_date]` → `dim_date[date_key]` (inaktive, bruges via `USERELATIONSHIP`)

## 2. Supabase: databasen

### 2.1 Skemaer og tabeller
Alle tabeller og procedurer oprettes af migrationerne i `supabase/migrations/` i navnerækkefølge:

1. `..._create_medallion_schemas.sql` – skemaerne `bronze`, `silver`, `gold`
2. `..._create_bronze_tables.sql` – 6 bronze-tabeller
3. `..._create_silver_tables.sql` – 6 silver-tabeller
4. `..._create_silver_load_procedure.sql` – `silver.load_silver()`
5. `..._create_gold_star_schema.sql` – gold-tabeller + `gold.load_gold()`
6. `..._powerbi_reader_access.sql` – read-only bruger, RLS-policies og fast `search_path`

### 2.2 Indlæs bronze
CSV-filerne indlæses i Supabase **Table Editor** (skema `bronze` → tabel → *Insert → Import data from CSV*).

- Kolonneoverskrifterne skal være med **små bogstaver**, ellers kobler importen ikke kolonnerne
  (ERP-filerne har store bogstaver i kilden og skal rettes først).
- Alternativ med `psql`: `scripts/load_bronze.ps1` (kræver `SUPABASE_DB_PASSWORD` og `SUPABASE_POOLER_HOST`).

Forventet antal rækker:

| Tabel | Rækker |
|---|---|
| crm_cust_info | 18.494 |
| crm_prd_info | 397 |
| crm_sales_details | 60.398 |
| erp_cust_az12 | 18.484 |
| erp_loc_a101 | 18.484 |
| erp_px_cat_g1v2 | 37 |

### 2.3 Byg silver og gold
Kør i Supabase SQL Editor:

```sql
call silver.load_silver();
call gold.load_gold();
```

Begge procedurer tømmer og genopbygger deres tabeller, så de kan køres igen når som helst.

### 2.4 Test
Kør `sql/tests/quality_checks_silver.sql` og `sql/tests/quality_checks_gold.sql`. Alle fejltjek skal give 0.
Kendte, accepterede afvigelser:

- 19 salgslinjer har ugyldig ordredato i kilden → `order_date` er tom.
- 15 kunder har fødselsdato før 1924; fremtidige fødselsdatoer er sat til tom i silver.

### 2.5 Power BI-bruger
Power BI logger på som `powerbi_reader` (kun læseadgang til `gold`). Password sættes manuelt og gemmes aldrig i repoet:

```sql
alter role powerbi_reader with password '<dit-password>';
```

> RLS er slået til på gold-tabellerne. Uden policies ser `powerbi_reader` 0 rækker – derfor policies i migration 6.

## 3. Power BI: forbindelse og Power Query

### 3.1 Forudsætninger
- Power BI Desktop (Store-versionen virker).
- **Supabase-rodcertifikat installeret i Windows**, ellers fejler forbindelsen med
  *"Fjerncertifikatet er ugyldigt"*:
  1. Supabase → *Project Settings → Database → SSL Configuration → Download certificate*.
  2. Dobbeltklik på `.crt` → *Installer certifikat* → *Aktuel bruger* →
     *Rodnøglecentre, der er tillid til* → Udfør.
  3. Genstart Power BI.

### 3.2 Åbn projektet
Åbn `output/dwh_gold/dwh_gold.pbip`. Filen skal ligge sammen med mapperne `dwh_gold.Report` og
`dwh_gold.SemanticModel` – en løs `.pbip` (fx i Downloads) giver fejlen *"Required artifact is missing"*.

### 3.3 Parametre
*Transformér data → Rediger parametre*:

| Parameter | Værdi |
|---|---|
| `PgServer` | Session pooler-host fra Supabase (*Connect → Session pooler*), fx `aws-0-eu-west-2.pooler.supabase.com` |
| `PgDatabase` | `postgres` |

Login: fanen **Database**, brugernavn `powerbi_reader.<projekt-id>`, password fra trin 2.5.

### 3.4 Forespørgsler i Power Query
Alle tabeller bruger den fælles forespørgsel `GoldKilde = PostgreSQL.Database(PgServer, PgDatabase)`:

| Forespørgsel | Kilde | Trin |
|---|---|---|
| `dim_customers` | `gold.dim_customers` | Vælg kolonner → sæt datatyper |
| `dim_products` | `gold.dim_products` | Vælg kolonner → sæt datatyper |
| `fact_sales` | `gold.fact_sales` | Vælg kolonner → sæt datatyper |
| `dim_date` | Genereres fra datoerne i `fact_sales` | Hele år fra første til sidste dato; år, kvartal, måned, uge, ugedag (dansk) |

Klik **Luk og anvend** og derefter **Opdater**. Forventet: `fact_sales` 60.398, `dim_customers` 18.484, `dim_products` 295 rækker.

## 4. Modellen i PBIP/TMDL

Modellen er tekstfiler, så ændringer kan ses i Git.

```
dwh_gold.SemanticModel/definition/
├── model.tmdl            # modelindstillinger + liste over tabeller
├── expressions.tmdl      # parametre PgServer, PgDatabase og GoldKilde
├── relationships.tmdl    # relationer (aktive og inaktive)
└── tables/
    ├── dim_customers.tmdl
    ├── dim_products.tmdl
    ├── dim_date.tmdl     # markeret som datotabel (dataCategory: Time, date_key er nøgle)
    ├── fact_sales.tmdl
    └── _Measures.tmdl    # alle measures
```

### 4.1 Regler ved redigering af TMDL
- **Luk Power BI**, før filerne redigeres – ellers overskriver Power BI ændringerne ved næste gem.
- Indrykning er **tabulatorer**.
- Navne med mellemrum eller specialtegn skrives i enkelt-anførselstegn: `measure 'Antal ordrer' = ...`.
- Flerlinjet DAX indrykkes ét niveau mere end egenskaberne (`formatString`, `displayFolder` …).
- Beskrivelser (`///`) er tilladt på tabeller, kolonner og measures – **ikke** på relationer.
- Alle objekter har et unikt `lineageTag` (GUID).

### 4.2 Measures (`_Measures`)

| Mappe | Measures |
|---|---|
| Salg | Omsætning, Antal ordrer, Antal ordrelinjer, Antal enheder, Gns. ordrelinje, Gns. ordreværdi, Kostpris, Dækningsbidrag, Margin % |
| Kunder | Antal kunder, Omsætning pr. kunde |
| Tidsintelligens | Omsætning YTD, Omsætning sidste år, Omsætning YoY, Omsætning YoY %, Omsætning YTD sidste år, Omsætning YTD YoY %, Omsætning efter afsendelsesdato, Omsætning efter forfaldsdato |
| Rangering | Produktrang, Omsætning top 10 produkter, Omsætning bund 10 produkter |
| Dashboard | Seneste/forrige måned, label og farve for omsætning, ordrer og kunder; Top underkategori; Top land |

Eksempler:

```dax
Kostpris = SUMX ( fact_sales, fact_sales[quantity] * RELATED ( dim_products[cost] ) )
Dækningsbidrag = [Omsætning] - [Kostpris]
Margin % = DIVIDE ( [Dækningsbidrag], [Omsætning] )

Omsætning efter afsendelsesdato =
CALCULATE ( [Omsætning], USERELATIONSHIP ( fact_sales[shipping_date], dim_date[date_key] ) )
```

Data slutter 28. januar 2014. Månedskortene bruger derfor **seneste hele måned** (december 2013)
via det skjulte measure `Seneste hele måned slut`.

## 5. Dashboardet "Salgsoverblik"

Siden "Dashboard" er bygget med layout-skillen `pbip-layout` (mørke KPI-fliser, trend, månedskort,
kategori-søjler, top 10-tabel og fremhævninger).

| Element | Indhold | Værdi |
|---|---|---|
| KPI-fliser | Omsætning, Ordrer, Dækningsbidrag, Margin % | 29.356.250 · 27.659 · 11.685.757 · 39,8 % |
| Trend | Omsætning pr. måned med trendlinje og zoom | 2010–2014 |
| Månedskort | Omsætning, ordrer, kunder i december 2013 vs. november | 1.874.128 (+5,2 %) · 2.192 (+5,0 %) · 2.133 (+4,8 %) |
| Søjler | Ordrer pr. kategori | Accessories 18.208 · Bikes 15.205 · Clothing 7.461 |
| Tabel | Top 10 produkter efter ordrer, med omsætning og margin % | Water Bottle – 30 oz. øverst |
| Fremhævninger | Mest bestilte underkategori, største land | Tires and Tubes · United States |

Der findes ingen returdata, så forlæggets "Return Rate" er erstattet af margin %.

## 6. Fejlfinding

| Fejl | Årsag | Løsning |
|---|---|---|
| *Fjerncertifikatet er ugyldigt* | Supabase-rodcertifikat mangler | Installér certifikatet (3.1) |
| *Required artifact is missing* | `.pbip` åbnet uden sine mapper | Åbn filen i `output/dwh_gold` |
| Tabeller tomme i Power BI | RLS uden policy for `powerbi_reader` | Kør migration 6 |
| *Property 'description' is unknown* | `///` foran en relation i TMDL | Fjern beskrivelsen |
| Rapporten går ned med `customTheme` | Rapporten mangler tema | Tema ligger i `StaticResources/SharedResources/BaseThemes` |
| Power BI åbner ikke / mærkelige fejl | Fuld disk | Frigør plads på C: (mindst et par GB) |

## 7. Opdatering af data

Intet opdateres automatisk:

1. Indlæs nye CSV-filer i bronze (2.2).
2. Kør `call silver.load_silver(); call gold.load_gold();` (2.3).
3. Klik **Opdater** i Power BI.

Planlagt opdatering kan tilføjes senere med `pg_cron` i Supabase.
