# Modelbeslutninger – dwh_gold

Beslutninger fra grill-sessionen 2026-10-29. Hver beslutning bygger på en forespørgsel på data (kolonnen
*Evidens*). Formatet følger skill'en `supabase-medallion-powerbi` (references/decision-interview.md).

| # | Beslutning | Evidens | Valg | Konsekvens | Implementeret |
|---|---|---|---|---|---|
| R1-1 | Projektets formål | Statiske data (dec. 2010 – jan. 2014), ingen planlagt opdatering | **A – demo-/referenceprojekt** med øje for genbrug | Korrekte og forklarlige tal går forud for automatisering; genbrug ligger i skill'en | – |
| R2-1 | Kostpris til margin | 77 produkter har skiftet kostpris; 19.054 af 60.398 salgslinjer berørt | **C – kostpris på salgslinjen** (`fact_sales.unit_cost`) slået op på ordredatoen; hul: seneste version startet før datoen, ellers første | Dækningsbidrag 11.685.757 → 12.389.834; margin 39,8 % → 42,2 % | Migration `20261029100000_model_decisions.sql`, measure `Kostpris` |
| R2-2 | 19 linjer uden ordredato | Alle øvrige 60.379 linjer afsendes præcis 7 dage efter ordre; 16 af 19 har søsterlinjer i samme ordre med gyldig dato | **B – afled i silver**: samme ordre først, ellers afsendelsesdato − 7; markeres `order_date_derived` | Alle linjer indgår i grafer over tid og YTD/YoY; omsætning 4.992 flyttes ind i aug.–okt. 2013 | Samme migration, kolonne i `fact_sales` |
| R2-3 | Køn når CRM og ERP er uenige | 57 kunder med forskelligt køn; ERP udfylder 4.554 kunder, hvor CRM mangler | **A – CRM er master**, ERP som fallback; konflikter tælles i et informations-tjek | Uændrede tal; konflikterne er synlige | `sql/tests/quality_checks_gold.sql` |
| R3-1 | "Ordrer" pr. kategori/produkt | Søjlerne summerer til 40.874 mod 27.659 ordrer; 11.250 ordrer (41 %) har flere kategorier | **A – behold antal ordrer**, men præcise titler | "Ordrer med kategorien" og kolonnen "Ordrer med produktet" | Dashboard-visuals |
| R3-2 | Ufuldstændige måneder i kanten | Dec. 2010: 3 dage (43.419); jan. 2014: 28 dage, men kun 45.642 (2,4 % af dec.; gns. ordre ~52 mod ~855) | **B – `dim_date[is_complete_month]`**; trend og sparklines viser hele måneder, totaler tæller alt | Ingen falsk kollaps i trendgrafen; jan. 2014 dokumenteret som kendt anomali (sandsynligt ufuldstændigt udtræk) | `dim_date`, measures `… hele måneder` |
| R3-3 | "Seneste måned" på kortene | Data slutter 28. jan. 2014 | Seneste **hele** måned (dec. 2013) | Kort viser dec. vs. nov. 2013 | Measures i mappen Dashboard (bygget tidligere) |
| R3-5 | KPI'er uden data | Ingen returdata | Margin % i stedet for returrate | Angivet i guiden | Dashboard |
| R4-1 | Offentligt repo | Repoet er offentligt; projekt-id, pooler-host og brugernavn var committet | **B – forbliv offentligt**, pladsholdere fremover, stærkt password, overvej netværksbegrænsning | Projekt-id/host fjernet fra sporede filer; `.mcp.json` er lokal (skabelon `.mcp.example.json`); gamle værdier findes stadig i Git-historikken | Denne commit |

## Arbejdsregler, der følger af beslutningerne

- **Power BI-parameteren `PgServer`** er en pladsholder i repoet (`aws-0-REGION.pooler.supabase.com`).
  Sæt din egen host lokalt, og ret den tilbage før commit – Power BI gemmer parameterværdien i
  `expressions.tmdl`.
- **`scripts/load_bronze.ps1`** læser projekt-id fra `SUPABASE_PROJECT_REF`.
- **Password** for `powerbi_reader`: langt, genereret og opbevaret i en password manager.
- Kør `sql/tests/quality_checks_gold.sql` efter hver load; fejltjek skal give 0, informations-tjek skal
  stemme med tallene ovenfor (19 afledte datoer, 57 kønskonflikter).
