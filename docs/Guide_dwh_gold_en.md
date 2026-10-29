# Guide: dwh_gold – from CSV to Power BI dashboard

Step-by-step guide to the `dwh_gold` data warehouse: the medallion layers in Supabase (bronze → silver → gold),
the Power BI model in PBIP/TMDL and the "Salgsoverblik" (Sales overview) dashboard.

> The model and report use Danish names (for example `Omsætning` = revenue, `Antal ordrer` = number of orders).
> English translations are given in parentheses where it helps.

## 1. Overview

| Layer | Where | Content |
|---|---|---|
| Bronze | Supabase, schema `bronze` | Raw CSV data, 1:1 with the source files (6 tables) |
| Silver | Supabase, schema `silver` | Cleaned and standardised data (`silver.load_silver()`) |
| Gold | Supabase, schema `gold` | Star schema: `dim_customers`, `dim_products`, `fact_sales` (`gold.load_gold()`) |
| Model | `output/dwh_gold/dwh_gold.SemanticModel` | Power BI model in TMDL, including `dim_date` and `_Measures` |
| Report | `output/dwh_gold/dwh_gold.Report` | PBIR report with the "Dashboard" page |

Diagram of the gold layer: `diagrams/dwh_gold.dbml` (paste it into https://dbdiagram.io/d).

### Star schema

- **Grain of `fact_sales`:** one row per order line (order number + product).
- **Dimensions:** `dim_customers` (customer, country, gender, marital status), `dim_products` (product, category,
  subcategory, unit cost – active products only), `dim_date` (calendar generated in Power Query).
- **Relationships (many-to-one):**
  - `fact_sales[customer_key]` → `dim_customers[customer_key]`
  - `fact_sales[product_key]` → `dim_products[product_key]`
  - `fact_sales[order_date]` → `dim_date[date_key]` (active)
  - `fact_sales[shipping_date]` and `fact_sales[due_date]` → `dim_date[date_key]` (inactive, used through `USERELATIONSHIP`)

## 2. Supabase: the database

### 2.1 Schemas and tables
All tables and procedures are created by the migrations in `supabase/migrations/`, in file-name order:

1. `..._create_medallion_schemas.sql` – schemas `bronze`, `silver`, `gold`
2. `..._create_bronze_tables.sql` – 6 bronze tables
3. `..._create_silver_tables.sql` – 6 silver tables
4. `..._create_silver_load_procedure.sql` – `silver.load_silver()`
5. `..._create_gold_star_schema.sql` – gold tables + `gold.load_gold()`
6. `..._powerbi_reader_access.sql` – read-only user, RLS policies and a fixed `search_path`
7. `..._revert_model_decisions.sql` – rolls back an earlier model change (no effect on a new database)
8. `..._schedule_daily_load.sql` – daily pg_cron job that builds silver and gold (section 7)

### 2.2 Load bronze
Load the CSV files with the Supabase **Table Editor** (schema `bronze` → table → *Insert → Import data from CSV*).

- Column headers must be **lower case**, otherwise the import cannot match the columns
  (the ERP files have upper-case headers in the source and must be fixed first).
- Alternative with `psql`: `scripts/load_bronze.ps1` (needs `SUPABASE_DB_PASSWORD` and `SUPABASE_POOLER_HOST`).

Expected row counts:

| Table | Rows |
|---|---|
| crm_cust_info | 18,494 |
| crm_prd_info | 397 |
| crm_sales_details | 60,398 |
| erp_cust_az12 | 18,484 |
| erp_loc_a101 | 18,484 |
| erp_px_cat_g1v2 | 37 |

### 2.3 Build silver and gold
Run in the Supabase SQL Editor:

```sql
call silver.load_silver();
call gold.load_gold();
```

Both procedures truncate and rebuild their tables, so they can be rerun at any time.

### 2.4 Tests
Run `sql/tests/quality_checks_silver.sql` and `sql/tests/quality_checks_gold.sql`. Every error check must return 0.
Known, accepted exceptions:

- 19 sales lines have an invalid order date in the source → `order_date` is empty.
- 15 customers have a birth date before 1924; future birth dates are set to empty in silver.

### 2.5 Power BI user
Power BI signs in as `powerbi_reader` (read access to `gold` only). Set the password manually and never store it in the repo:

```sql
alter role powerbi_reader with password '<your-password>';
```

> RLS is enabled on the gold tables. Without policies `powerbi_reader` sees 0 rows – hence the policies in migration 6.

## 3. Power BI: connection and Power Query

### 3.1 Prerequisites
- Power BI Desktop (the Microsoft Store version works).
- **Supabase root certificate installed in Windows**, otherwise the connection fails with
  *"The remote certificate is invalid according to the validation procedure"*:
  1. Supabase → *Project Settings → Database → SSL Configuration → Download certificate*.
  2. Double-click the `.crt` file → *Install Certificate* → *Current User* →
     *Trusted Root Certification Authorities* → Finish.
  3. Restart Power BI.

### 3.2 Open the project
Open `output/dwh_gold/dwh_gold.pbip`. The file must sit next to the `dwh_gold.Report` and
`dwh_gold.SemanticModel` folders – a loose `.pbip` (for example in Downloads) gives the error *"Required artifact is missing"*.

### 3.3 Parameters
*Transform data → Edit parameters*:

| Parameter | Value |
|---|---|
| `PgServer` | Session pooler host from Supabase (*Connect → Session pooler*), e.g. `aws-0-eu-west-2.pooler.supabase.com` |
| `PgDatabase` | `postgres` |

Sign-in: the **Database** tab, user name `powerbi_reader.<project-id>`, password from step 2.5.

### 3.4 Power Query queries
All tables use the shared query `GoldKilde = PostgreSQL.Database(PgServer, PgDatabase)` ("GoldKilde" = gold source):

| Query | Source | Steps |
|---|---|---|
| `dim_customers` | `gold.dim_customers` | Select columns → set data types |
| `dim_products` | `gold.dim_products` | Select columns → set data types |
| `fact_sales` | `gold.fact_sales` | Select columns → set data types |
| `dim_date` | Generated from the dates in `fact_sales` | Whole years from first to last date; year, quarter, month, week, weekday (Danish) |

Click **Close & Apply**, then **Refresh**. Expected: `fact_sales` 60,398, `dim_customers` 18,484, `dim_products` 295 rows.

## 4. The model in PBIP/TMDL

The model is stored as text files, so changes show up in Git.

```
dwh_gold.SemanticModel/definition/
├── model.tmdl            # model settings + list of tables
├── expressions.tmdl      # parameters PgServer, PgDatabase and GoldKilde
├── relationships.tmdl    # relationships (active and inactive)
└── tables/
    ├── dim_customers.tmdl
    ├── dim_products.tmdl
    ├── dim_date.tmdl     # marked as date table (dataCategory: Time, date_key is the key)
    ├── fact_sales.tmdl
    └── _Measures.tmdl    # all measures
```

### 4.1 Rules for editing TMDL
- **Close Power BI** before editing the files – otherwise Power BI overwrites your changes the next time it saves.
- Indentation uses **tabs**.
- Names with spaces or special characters go in single quotes: `measure 'Antal ordrer' = ...`.
- Multi-line DAX is indented one level deeper than the properties (`formatString`, `displayFolder` …).
- Descriptions (`///`) are allowed on tables, columns and measures – **not** on relationships.
- Every object has a unique `lineageTag` (GUID).

### 4.2 Measures (`_Measures`)

| Folder | Measures |
|---|---|
| Salg (Sales) | Omsætning (revenue), Antal ordrer (orders), Antal ordrelinjer (order lines), Antal enheder (units), Gns. ordrelinje (avg. order line), Gns. ordreværdi (avg. order value), Kostpris (cost), Dækningsbidrag (gross margin), Margin % |
| Kunder (Customers) | Antal kunder (customers), Omsætning pr. kunde (revenue per customer) |
| Tidsintelligens (Time intelligence) | Omsætning YTD, Omsætning sidste år (last year), Omsætning YoY, Omsætning YoY %, Omsætning YTD sidste år, Omsætning YTD YoY %, Omsætning efter afsendelsesdato (by ship date), Omsætning efter forfaldsdato (by due date) |
| Rangering (Ranking) | Produktrang (product rank), Omsætning top 10 produkter, Omsætning bund 10 produkter (bottom 10) |
| Dashboard | Latest/previous month, label and colour for revenue, orders and customers; Top underkategori (top subcategory); Top land (top country) |

Examples:

```dax
Kostpris = SUMX ( fact_sales, fact_sales[quantity] * RELATED ( dim_products[cost] ) )
Dækningsbidrag = [Omsætning] - [Kostpris]
Margin % = DIVIDE ( [Dækningsbidrag], [Omsætning] )

Omsætning efter afsendelsesdato =
CALCULATE ( [Omsætning], USERELATIONSHIP ( fact_sales[shipping_date], dim_date[date_key] ) )
```

The data ends on 28 January 2014. The monthly cards therefore use the **latest complete month** (December 2013)
through the hidden measure `Seneste hele måned slut` (end of latest complete month).

## 5. The "Salgsoverblik" dashboard

The "Dashboard" page was built with the `pbip-layout` skill (dark KPI tiles, trend, monthly cards,
category bars, top 10 table and highlight tiles).

| Element | Content | Value |
|---|---|---|
| KPI tiles | Revenue, Orders, Gross margin, Margin % | 29,356,250 · 27,659 · 11,685,757 · 39.8% |
| Trend | Revenue per month with trend line and zoom | 2010–2014 |
| Monthly cards | Revenue, orders, customers in December 2013 vs. November | 1,874,128 (+5.2%) · 2,192 (+5.0%) · 2,133 (+4.8%) |
| Bars | Orders per category | Accessories 18,208 · Bikes 15,205 · Clothing 7,461 |
| Table | Top 10 products by orders, with revenue and margin % | Water Bottle – 30 oz. at the top |
| Highlights | Most ordered subcategory, largest country | Tires and Tubes · United States |

There is no returns data, so the template's "Return Rate" was replaced by margin %.

## 6. Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| *The remote certificate is invalid* | Supabase root certificate missing | Install the certificate (3.1) |
| *Required artifact is missing* | `.pbip` opened without its folders | Open the file in `output/dwh_gold` |
| Empty tables in Power BI | RLS without a policy for `powerbi_reader` | Run migration 6 |
| *Property 'description' is unknown* | `///` in front of a relationship in TMDL | Remove the description |
| Report crashes with `customTheme` | Report has no theme | Theme lives in `StaticResources/SharedResources/BaseThemes` |
| KPI tiles render white | The card's inner tile (`fillCustom`) is drawn on top of the dark container | Set `fillCustom.transparency` to 100 |
| Power BI won't open / odd errors | Full disk | Free space on C: (at least a few GB) |

## 7. Refreshing data

1. Load new CSV files into bronze (2.2). This is **manual**.
2. Silver and gold are rebuilt **automatically** every day (see 7.1). To skip the wait, run `call silver.load_silver(); call gold.load_gold();` (2.3).
3. Click **Refresh** in Power BI. This is **manual** as long as the report only lives in Desktop.

### 7.1 Daily job (pg_cron)
Migration 8 creates the job `daily_load_silver_gold`:

| | |
|---|---|
| Schedule | `0 5 * * *` = 05:00 UTC (06:00 Danish winter time, 07:00 summer time) |
| Command | `call silver.load_silver(); call gold.load_gold();` |

Run in the SQL Editor:

```sql
-- The job
select jobid, jobname, schedule, command, active from cron.job;

-- Latest runs (status should be 'succeeded')
select status, return_message, start_time, end_time
from cron.job_run_details order by start_time desc limit 10;

-- Change the time (the same name updates the job)
select cron.schedule('daily_load_silver_gold', '0 4 * * *',
    $$call silver.load_silver(); call gold.load_gold();$$);

-- Stop the job
select cron.unschedule('daily_load_silver_gold');
```

Note:
- The job only builds from what is in bronze. Without new CSV data it produces the same numbers.
- The free plan pauses the project after about 7 days without activity, and then the job does not run. Restart it under *Restore* in Supabase.
