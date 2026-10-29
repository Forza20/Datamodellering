# Data lineage – sales_model

Genereret 2026-10-29 20:32 af pbip-catalog. Farver: sort = datakilde, grå = Power Query, mørk = tabel, hvid = kolonne, turkis = measure, rosa = dashboard.

[[_TOC_]]

## Overblik (tabelniveau)

Datakilder → delte Power Query-queries → tabeller → rapportsider.

::: mermaid
flowchart LR
    n0("Kilde")
    n1(["Excel File: C:\Users\maria\Desktop\Claude\Data Modeling\data\silver\Silver_Excel.xlsx"])
    n2("slv_customer")
    n3("slv_address")
    n4("slv_city")
    n5("slv_credit")
    n6("slv_contact")
    n7("slv_product")
    n8("slv_subcategory")
    n9("slv_order")
    n10("slv_order_line")
    n11("slv_campaign_log")
    n12("slv_campaign_sku")
    n13("slv_inventory")
    n14("slv_sales_target")
    n15("slv_security")
    n16["_measures"]
    n17["bridge_campaign_product"]
    n18["dim_campaign"]
    n19["dim_product"]
    n20["dim_channel"]
    n21["dim_customer"]
    n22["dim_date"]
    n23["dim_region"]
    n24["fact_campaign_spend"]
    n25["fact_inventory"]
    n26["fact_sales"]
    n27["fact_sales_target"]
    n28["security"]
    n1 --> n0
    n0 --> n2
    n0 --> n3
    n0 --> n4
    n0 --> n5
    n0 --> n6
    n0 --> n7
    n0 --> n8
    n0 --> n9
    n0 --> n10
    n0 --> n11
    n0 --> n12
    n0 --> n13
    n0 --> n14
    n0 --> n15
    n12 --> n17
    n18 --> n17
    n19 --> n17
    n11 --> n18
    n3 --> n21
    n4 --> n21
    n6 --> n21
    n5 --> n21
    n2 --> n21
    n11 --> n22
    n13 --> n22
    n9 --> n22
    n14 --> n22
    n7 --> n19
    n8 --> n19
    n4 --> n23
    n11 --> n24
    n18 --> n24
    n13 --> n25
    n19 --> n25
    n9 --> n26
    n10 --> n26
    n20 --> n26
    n21 --> n26
    n19 --> n26
    n23 --> n26
    n14 --> n27
    n15 --> n28
    classDef qry fill:#E1DFDD,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    class n0,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15 qry
    class n1 src
    class n16,n17,n18,n19,n20,n21,n22,n23,n24,n25,n26,n27,n28 tbl
:::

## Kolonne-lineage pr. tabel

<details>
<summary><b>bridge_campaign_product</b> (2 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `campaign_key` | Beregnet i dim_campaign (trin MedKey) | dim_campaign: Indeks/nøgle (Fortløbende nummer fra 1) → bridge_campaign_product: Hentet via join (dim_campaign[campaign_key]) |
| `product_key` | Beregnet i dim_product (trin MedKey) | dim_product: Indeks/nøgle (Fortløbende nummer fra 1) → dim_product: Samlet (append) (Typer, Ukendt) → bridge_campaign_product: Hentet via join (dim_product[product_key]) |

</details>

<details>
<summary><b>dim_campaign</b> (6 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `campaign_key` | Beregnet i dim_campaign (trin MedKey) | dim_campaign: Indeks/nøgle (Fortløbende nummer fra 1) |
| `campaign_name` | CAMPAIGN_LOG (Sheet).CampaignName | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → slv_campaign_log: Transformeret ({"CampaignName", Text.Trim, type text}) → dim_campaign: Omdøbt (CampaignName → campaign_name) |
| `marketing_channel` | CAMPAIGN_LOG (Sheet).Channel | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → slv_campaign_log: Transformeret ({"Channel", Text.Trim, type text}) → dim_campaign: Omdøbt (Channel → marketing_channel) |
| `start_date` | CAMPAIGN_LOG (Sheet).StartDate | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → dim_campaign: Omdøbt (StartDate → start_date) |
| `end_date` | CAMPAIGN_LOG (Sheet).EndDate | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → dim_campaign: Omdøbt (EndDate → end_date) |
| `budget` | CAMPAIGN_LOG (Sheet).Budget | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → dim_campaign: Omdøbt (Budget → budget) |

</details>

<details>
<summary><b>dim_channel</b> (2 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `channel_key` | Beregnet i dim_channel (trin Kanaler) | – |
| `channel_name` | Beregnet i dim_channel (trin Kanaler) | – |

</details>

<details>
<summary><b>dim_customer</b> (11 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `customer_key` | Beregnet i dim_customer (trin MedKey) | dim_customer: Indeks/nøgle (Fortløbende nummer fra 1) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `customer_id` | CUST_MASTER (Sheet).CustomerID | slv_customer: Navigation (CUST_MASTER (Sheet)) → dim_customer: Omdøbt (CustomerID → customer_id) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `customer_name` | CUST_MASTER (Sheet).CustomerName | slv_customer: Navigation (CUST_MASTER (Sheet)) → slv_customer: Transformeret ({"CustomerName", Text.Trim, type text}) → dim_customer: Omdøbt (CustomerName → customer_name) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `segment` | CUST_MASTER (Sheet).Segment | slv_customer: Navigation (CUST_MASTER (Sheet)) → slv_customer: Transformeret ({"Segment", Text.Trim, type text}) → dim_customer: Omdøbt (Segment → segment) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `account_manager` | CUST_MASTER (Sheet).AccountManager | slv_customer: Navigation (CUST_MASTER (Sheet)) → slv_customer: Transformeret ({"AccountManager", Text.Trim, type text}) → dim_customer: Omdøbt (AccountManager → account_manager) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `payment_terms` | CUST_MASTER (Sheet).PaymentTerms | slv_customer: Navigation (CUST_MASTER (Sheet)) → slv_customer: Transformeret ({"PaymentTerms", Text.Trim, type text}) → dim_customer: Omdøbt (PaymentTerms → payment_terms) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `credit_limit` | user_details (Sheet).CreditLimit | slv_credit: Navigation (user_details (Sheet)) → dim_customer: Hentet via join (slv_credit[CreditLimit]) → dim_customer: Omdøbt (CreditLimit → credit_limit) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `street` | Address (Sheet).Street | slv_address: Navigation (Address (Sheet)) → slv_address: Transformeret ({"Street", Text.Trim, type text}) → dim_customer: Hentet via join (slv_address[Street]) → dim_customer: Omdøbt (Street → street) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `city` | Address (Sheet).CityName | slv_address: Navigation (Address (Sheet)) → slv_address: Transformeret ({"CityName", Text.Trim, type text}) → dim_customer: Hentet via join (slv_address[CityName]) → dim_customer: Omdøbt (CityName → city) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `region` | cities (Sheet).RegionName | slv_city: Navigation (cities (Sheet)) → slv_city: Transformeret ({"RegionName", Text.Trim, type text}) → dim_customer: Hentet via join (slv_city[RegionName]) → dim_customer: Omdøbt (RegionName → region) → dim_customer: Samlet (append) (Typer, Ukendt) |
| `primary_contact` | customer_contacts (Sheet).ContactName | slv_contact: Navigation (customer_contacts (Sheet)) → slv_contact: Transformeret ({"ContactName", Text.Trim, type text}) → dim_customer: Hentet via join (slv_contact[ContactName]) → dim_customer: Omdøbt (ContactName → primary_contact) → dim_customer: Samlet (append) (Typer, Ukendt) |

</details>

<details>
<summary><b>dim_date</b> (8 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `date_key` | Beregnet i dim_date (trin Start) | – |
| `year` | Beregnet i dim_date (trin Aar) | dim_date: Beregnet (each Date.Year([date_key])) |
| `quarter` | Beregnet i dim_date (trin Kvartal) | dim_date: Beregnet (each "K" & Text.From(Date.QuarterOfYear([date_key]))) |
| `month_no` | Beregnet i dim_date (trin MaanedNr) | dim_date: Beregnet (each Date.Month([date_key])) |
| `month_name` | Beregnet i dim_date (trin Maaned) | dim_date: Beregnet (each Date.ToText([date_key], [Format = "MMM", Culture = "da…) |
| `year_month` | Beregnet i dim_date (trin AarMaaned) | dim_date: Beregnet (each Date.ToText([date_key], [Format = "yyyy-MM"])) |
| `month_start` | Beregnet i dim_date (trin Maanedstart) | dim_date: Beregnet (each Date.StartOfMonth([date_key])) |
| `week_no` | Beregnet i dim_date (trin Uge) | dim_date: Beregnet (each Date.WeekOfYear([date_key], Day.Monday)) |

</details>

<details>
<summary><b>dim_product</b> (8 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `product_key` | Beregnet i dim_product (trin MedKey) | dim_product: Indeks/nøgle (Fortløbende nummer fra 1) → dim_product: Samlet (append) (Typer, Ukendt) |
| `product_code` | products (Sheet).ProductCode | slv_product: Navigation (products (Sheet)) → slv_product: Transformeret ({"ProductCode", Text.Trim, type text}) → dim_product: Omdøbt (ProductCode → product_code) → dim_product: Samlet (append) (Typer, Ukendt) |
| `product_name` | products (Sheet).ProductName | slv_product: Navigation (products (Sheet)) → slv_product: Transformeret ({"ProductName", Text.Trim, type text}) → dim_product: Omdøbt (ProductName → product_name) → dim_product: Samlet (append) (Typer, Ukendt) |
| `brand` | products (Sheet).Brand | slv_product: Navigation (products (Sheet)) → slv_product: Transformeret ({"Brand", Text.Trim, type text}) → dim_product: Omdøbt (Brand → brand) → dim_product: Samlet (append) (Typer, Ukendt) |
| `category` | subcategories (Sheet).CategorySubcategory | slv_subcategory: Navigation (subcategories (Sheet)) → slv_subcategory: Opdelt (CategorySubcategory → Category (skilletegn "\|")) → slv_subcategory: Transformeret ({"Category", each Text.Proper(Text.Trim(_)), type text}) → dim_product: Hentet via join (SubLower[Category]) → dim_product: Omdøbt (Category → category) → dim_product: Samlet (append) (Typer, Ukendt) |
| `subcategory` | subcategories (Sheet).CategorySubcategory | slv_subcategory: Navigation (subcategories (Sheet)) → slv_subcategory: Opdelt (CategorySubcategory → Subcategory (skilletegn "\|")) → slv_subcategory: Transformeret ({"Subcategory", each Text.Proper(Text.Trim(_)), type text}) → dim_product: Hentet via join (SubLower[Subcategory]) → dim_product: Omdøbt (Subcategory → subcategory) → dim_product: Samlet (append) (Typer, Ukendt) |
| `list_price` | products (Sheet).UnitPrice | slv_product: Navigation (products (Sheet)) → dim_product: Omdøbt (UnitPrice → list_price) → dim_product: Samlet (append) (Typer, Ukendt) |
| `primary_supplier` | products (Sheet).PrimarySupplier | slv_product: Navigation (products (Sheet)) → slv_product: Transformeret ({"PrimarySupplier", Text.Trim, type text}) → dim_product: Omdøbt (PrimarySupplier → primary_supplier) → dim_product: Samlet (append) (Typer, Ukendt) |

</details>

<details>
<summary><b>dim_region</b> (2 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `region_key` | Beregnet i dim_region (trin MedKey) | dim_region: Indeks/nøgle (Fortløbende nummer fra 1) → dim_region: Samlet (append) (Typer, Ukendt) |
| `region_name` | cities (Sheet).RegionName | slv_city: Navigation (cities (Sheet)) → slv_city: Transformeret ({"RegionName", Text.Trim, type text}) → dim_region: Omdøbt (RegionName → region_name) → dim_region: Samlet (append) (Typer, Ukendt) |

</details>

<details>
<summary><b>fact_campaign_spend</b> (5 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `date_key` | CAMPAIGN_LOG (Sheet).Date | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → fact_campaign_spend: Omdøbt (Date → date_key) |
| `campaign_key` | Beregnet i dim_campaign (trin MedKey) | dim_campaign: Indeks/nøgle (Fortløbende nummer fra 1) → fact_campaign_spend: Hentet via join (dim_campaign[campaign_key]) |
| `impressions` | CAMPAIGN_LOG (Sheet).Impressions | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → fact_campaign_spend: Omdøbt (Impressions → impressions) |
| `clicks` | CAMPAIGN_LOG (Sheet).Clicks | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → fact_campaign_spend: Omdøbt (Clicks → clicks) |
| `spend` | CAMPAIGN_LOG (Sheet).Spend | slv_campaign_log: Navigation (CAMPAIGN_LOG (Sheet)) → fact_campaign_spend: Omdøbt (Spend → spend) |

</details>

<details>
<summary><b>fact_inventory</b> (3 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `date_key` | Beregnet i slv_inventory (trin MedDato) | slv_inventory: Beregnet (each Date.FromText([Period] & "-01", [Format = "yyyy-MM-dd"…) → fact_inventory: Omdøbt (MonthStart → date_key) |
| `product_key` | Beregnet i dim_product (trin MedKey) | dim_product: Indeks/nøgle (Fortløbende nummer fra 1) → dim_product: Samlet (append) (Typer, Ukendt) → fact_inventory: Hentet via join (dim_product[product_key]) → fact_inventory: Værdier erstattet (null, -1) |
| `stock_qty` | inventory (Sheet).(alle kolonner undtagen ProductName) | slv_inventory: Navigation (inventory (Sheet)) → slv_inventory: Unpivot (StockQty = værdier fra alle kolonner undtagen ProductName) → fact_inventory: Omdøbt (StockQty → stock_qty) |

</details>

<details>
<summary><b>fact_sales</b> (16 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `line_id` | order_line_items (Sheet).LineID | slv_order_line: Navigation (order_line_items (Sheet)) → slv_order_line: Transformeret ({"LineID", Text.Trim, type text}) → fact_sales: Omdøbt (LineID → line_id) |
| `order_id` | order_line_items (Sheet).OrderID | slv_order_line: Navigation (order_line_items (Sheet)) → slv_order_line: Transformeret ({"OrderID", Text.Trim, type text}) → fact_sales: Omdøbt (OrderID → order_id) |
| `date_key` | ORDERS_2025 (Sheet).OrderDate | slv_order: Navigation (ORDERS_2025 (Sheet)) → slv_order: Samlet (append) (Ark25, Ark26) → slv_order: Transformeret ({"OrderDate", Date.From, type date}) → fact_sales: Hentet via join (slv_order[OrderDate]) → fact_sales: Omdøbt (OrderDate → date_key) |
| `customer_key` | Beregnet i dim_customer (trin MedKey) | dim_customer: Indeks/nøgle (Fortløbende nummer fra 1) → dim_customer: Samlet (append) (Typer, Ukendt) → fact_sales: Hentet via join (dim_customer[customer_key]) → fact_sales: Værdier erstattet (null, -1) |
| `product_key` | Beregnet i dim_product (trin MedKey) | dim_product: Indeks/nøgle (Fortløbende nummer fra 1) → dim_product: Samlet (append) (Typer, Ukendt) → fact_sales: Hentet via join (dim_product[product_key]) → fact_sales: Værdier erstattet (null, -1) |
| `channel_key` | Beregnet i dim_channel (trin Kanaler) | fact_sales: Hentet via join (dim_channel[channel_key]) → fact_sales: Værdier erstattet (null, -1) |
| `region_key` | Beregnet i dim_region (trin MedKey) | dim_region: Indeks/nøgle (Fortløbende nummer fra 1) → dim_region: Samlet (append) (Typer, Ukendt) → fact_sales: Hentet via join (dim_region[region_key]) → fact_sales: Værdier erstattet (null, -1) |
| `order_status` | ORDERS_2025 (Sheet).Status | slv_order: Navigation (ORDERS_2025 (Sheet)) → slv_order: Samlet (append) (Ark25, Ark26) → slv_order: Transformeret ({"Status", Text.Trim, type text}) → fact_sales: Hentet via join (slv_order[Status]) → fact_sales: Transformeret ({"Status", each if _ = "Delivered" then "Leveret" else if _…) → fact_sales: Omdøbt (Status → order_status) |
| `order_priority` | ORDERS_2025 (Sheet).Priority | slv_order: Navigation (ORDERS_2025 (Sheet)) → slv_order: Samlet (append) (Ark25, Ark26) → slv_order: Transformeret ({"Priority", Text.Trim, type text}) → fact_sales: Hentet via join (slv_order[Priority]) → fact_sales: Transformeret ({"Priority", each if _ = "Express" then "Ekspres" else _, t…) → fact_sales: Omdøbt (Priority → order_priority) |
| `quantity` | order_line_items (Sheet).Quantity | slv_order_line: Navigation (order_line_items (Sheet)) → fact_sales: Omdøbt (Quantity → quantity) |
| `unit_price` | order_line_items (Sheet).UnitPrice | slv_order_line: Navigation (order_line_items (Sheet)) → fact_sales: Omdøbt (UnitPrice → unit_price) |
| `discount_pct` | order_line_items (Sheet).DiscountPct | slv_order_line: Navigation (order_line_items (Sheet)) → slv_order_line: Værdier erstattet (null, 0) → fact_sales: Omdøbt (DiscountPct → discount_pct) |
| `gross_amount` | Beregnet i fact_sales (trin Brutto) | fact_sales: Beregnet (each Number.Round([Quantity] * [UnitPrice], 2)) |
| `discount_amount` | Beregnet i fact_sales (trin Rabat) | fact_sales: Beregnet (each [gross_amount] - [net_amount]) |
| `net_amount` | Beregnet i fact_sales (trin Netto) | fact_sales: Beregnet (each Number.Round([gross_amount] * (1 - [DiscountPct]), 2)) |
| `cost_amount` | Beregnet i fact_sales (trin Kost) | fact_sales: Beregnet (each Number.Round([Quantity] * [UnitCost], 2)) |

</details>

<details>
<summary><b>fact_sales_target</b> (2 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `date_key` | Beregnet i slv_sales_target (trin MedDato) | slv_sales_target: Beregnet (each Date.FromText(Text.Trim([Period]) & "-01", [Format = "…) → fact_sales_target: Omdøbt (MonthStart → date_key) |
| `target_amount` | sales_targets (Sheet).TargetRevenue | slv_sales_target: Navigation (sales_targets (Sheet)) → fact_sales_target: Omdøbt (TargetRevenue → target_amount) |

</details>

<details>
<summary><b>security</b> (2 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `user_email` | security (Sheet).UserEmail | slv_security: Navigation (security (Sheet)) → slv_security: Transformeret ({"UserEmail", each Text.Lower(Text.Trim(_)), type text}) → security: Omdøbt (UserEmail → user_email) |
| `region` | security (Sheet).Region | slv_security: Navigation (security (Sheet)) → slv_security: Transformeret ({"Region", Text.Trim, type text}) → security: Omdøbt (Region → region) |

</details>
