# Data lineage – dwh_gold

Genereret 2026-10-29 20:00 af pbip-catalog. Farver: sort = datakilde, grå = Power Query, mørk = tabel, hvid = kolonne, turkis = measure, rosa = dashboard.

## Overblik (tabelniveau)

Datakilder → delte Power Query-queries → tabeller → rapportsider.

```mermaid
flowchart LR
    n0("GoldKilde")
    n1(["PostgreSQL: aws-0-eu-west-2.pooler.supabase.com / postgres"])
    n2["_Measures"]
    n3["dim_customers"]
    n4["dim_date"]
    n5["fact_sales"]
    n6["dim_products"]
    n7{{"Side: Dashboard"}}
    n1 --> n0
    n0 --> n3
    n5 --> n4
    n0 --> n6
    n0 --> n5
    n2 --> n7
    n3 --> n7
    n4 --> n7
    n6 --> n7
    n5 --> n7
    classDef qry fill:#E1DFDD,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    classDef page fill:#FDEDEF,color:#252423,stroke:#E36C78
    class n0 qry
    class n1 src
    class n2,n3,n4,n5,n6 tbl
    class n7 page
```

## Dashboard-pladser

Én graf pr. plads på dashboard-siden fra pbip-layout: measure → afhængige measures → kolonner → oprindelse i kilden.

### KPI 1

```mermaid
flowchart LR
    n0{{"KPI 1"}}
    n1("[Omsætning]")
    n2["fact_sales[sales_amount]"]
    n3(["gold.fact_sales.sales_amount"])
    n1 --> n0
    n2 --> n1
    n3 --> n2
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    class n0 slot
    class n1 msr
    class n2 col
    class n3 src
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `fact_sales[sales_amount]` | gold.fact_sales.sales_amount | fact_sales: Navigation (gold.fact_sales) |

### KPI 2

```mermaid
flowchart LR
    n0{{"KPI 2"}}
    n1("[Antal ordrer]")
    n2["fact_sales[order_number]"]
    n3(["gold.fact_sales.order_number"])
    n1 --> n0
    n2 --> n1
    n3 --> n2
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    class n0 slot
    class n1 msr
    class n2 col
    class n3 src
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `fact_sales[order_number]` | gold.fact_sales.order_number | fact_sales: Navigation (gold.fact_sales) |

### KPI 3

```mermaid
flowchart LR
    n0{{"KPI 3"}}
    n1("[Dækningsbidrag]")
    n2("[Kostpris]")
    n3["dim_products[cost]"]
    n4(["gold.dim_products.cost"])
    n5["fact_sales[quantity]"]
    n6(["gold.fact_sales.quantity"])
    n7["fact_sales"]
    n8("[Omsætning]")
    n9["fact_sales[sales_amount]"]
    n10(["gold.fact_sales.sales_amount"])
    n1 --> n0
    n2 --> n1
    n3 --> n2
    n4 --> n3
    n5 --> n2
    n6 --> n5
    n7 --> n2
    n8 --> n1
    n9 --> n8
    n10 --> n9
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    class n0 slot
    class n1,n2,n8 msr
    class n3,n5,n9 col
    class n4,n6,n10 src
    class n7 tbl
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_products[cost]` | gold.dim_products.cost | dim_products: Navigation (gold.dim_products) |
| `fact_sales[quantity]` | gold.fact_sales.quantity | fact_sales: Navigation (gold.fact_sales) |
| `fact_sales[sales_amount]` | gold.fact_sales.sales_amount | fact_sales: Navigation (gold.fact_sales) |

### KPI 4

```mermaid
flowchart LR
    n0{{"KPI 4"}}
    n1("[Margin %]")
    n2("[Dækningsbidrag]")
    n3("[Kostpris]")
    n4["dim_products[cost]"]
    n5(["gold.dim_products.cost"])
    n6["fact_sales[quantity]"]
    n7(["gold.fact_sales.quantity"])
    n8["fact_sales"]
    n9("[Omsætning]")
    n10["fact_sales[sales_amount]"]
    n11(["gold.fact_sales.sales_amount"])
    n1 --> n0
    n2 --> n1
    n3 --> n2
    n4 --> n3
    n5 --> n4
    n6 --> n3
    n7 --> n6
    n8 --> n3
    n9 --> n2
    n10 --> n9
    n11 --> n10
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    class n0 slot
    class n1,n2,n3,n9 msr
    class n4,n6,n10 col
    class n5,n7,n11 src
    class n8 tbl
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_products[cost]` | gold.dim_products.cost | dim_products: Navigation (gold.dim_products) |
| `fact_sales[quantity]` | gold.fact_sales.quantity | fact_sales: Navigation (gold.fact_sales) |
| `fact_sales[sales_amount]` | gold.fact_sales.sales_amount | fact_sales: Navigation (gold.fact_sales) |

### Trend

```mermaid
flowchart LR
    n0{{"Trend"}}
    n1["dim_date[month_start]"]
    n2("[Omsætning]")
    n3["fact_sales[sales_amount]"]
    n4(["gold.fact_sales.sales_amount"])
    n1 --> n0
    n2 --> n0
    n3 --> n2
    n4 --> n3
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    class n0 slot
    class n1,n3 col
    class n2 msr
    class n4 src
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_date[month_start]` | Beregnet i dim_date (trin Maanedstart) | dim_date: Beregnet (each Date.StartOfMonth([date_key])) |
| `fact_sales[sales_amount]` | gold.fact_sales.sales_amount | fact_sales: Navigation (gold.fact_sales) |

### Månedskort 1

```mermaid
flowchart LR
    n0{{"Månedskort 1"}}
    n1["dim_date[month_start]"]
    n2("[Omsætning]")
    n3["fact_sales[sales_amount]"]
    n4(["gold.fact_sales.sales_amount"])
    n5("[Omsætning seneste måned]")
    n6("[Seneste hele måned slut]")
    n7["fact_sales[order_date]"]
    n8(["gold.fact_sales.order_date"])
    n9["dim_date"]
    n10["dim_date[date_key]"]
    n11("[Omsætning måned farve]")
    n12("[Omsætning forrige måned]")
    n13("[Omsætning måned label]")
    n1 --> n0
    n2 --> n0
    n3 --> n2
    n4 --> n3
    n5 --> n0
    n6 --> n5
    n7 --> n6
    n8 --> n7
    n9 --> n6
    n10 --> n5
    n9 --> n5
    n11 --> n0
    n12 --> n11
    n10 --> n12
    n9 --> n12
    n13 --> n0
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    class n0 slot
    class n1,n3,n7,n10 col
    class n2,n5,n6,n11,n12,n13 msr
    class n4,n8 src
    class n9 tbl
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_date[date_key]` | Beregnet i dim_date (trin Start) | – |
| `dim_date[month_start]` | Beregnet i dim_date (trin Maanedstart) | dim_date: Beregnet (each Date.StartOfMonth([date_key])) |
| `fact_sales[order_date]` | gold.fact_sales.order_date | fact_sales: Navigation (gold.fact_sales) |
| `fact_sales[sales_amount]` | gold.fact_sales.sales_amount | fact_sales: Navigation (gold.fact_sales) |

### Månedskort 2

```mermaid
flowchart LR
    n0{{"Månedskort 2"}}
    n1["dim_date[month_start]"]
    n2("[Antal ordrer]")
    n3["fact_sales[order_number]"]
    n4(["gold.fact_sales.order_number"])
    n5("[Ordrer seneste måned]")
    n6("[Seneste hele måned slut]")
    n7["fact_sales[order_date]"]
    n8(["gold.fact_sales.order_date"])
    n9["dim_date"]
    n10["dim_date[date_key]"]
    n11("[Ordrer måned farve]")
    n12("[Ordrer forrige måned]")
    n13("[Ordrer måned label]")
    n1 --> n0
    n2 --> n0
    n3 --> n2
    n4 --> n3
    n5 --> n0
    n6 --> n5
    n7 --> n6
    n8 --> n7
    n9 --> n6
    n10 --> n5
    n9 --> n5
    n11 --> n0
    n12 --> n11
    n10 --> n12
    n9 --> n12
    n13 --> n0
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    class n0 slot
    class n1,n3,n7,n10 col
    class n2,n5,n6,n11,n12,n13 msr
    class n4,n8 src
    class n9 tbl
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_date[date_key]` | Beregnet i dim_date (trin Start) | – |
| `dim_date[month_start]` | Beregnet i dim_date (trin Maanedstart) | dim_date: Beregnet (each Date.StartOfMonth([date_key])) |
| `fact_sales[order_date]` | gold.fact_sales.order_date | fact_sales: Navigation (gold.fact_sales) |
| `fact_sales[order_number]` | gold.fact_sales.order_number | fact_sales: Navigation (gold.fact_sales) |

### Månedskort 3

```mermaid
flowchart LR
    n0{{"Månedskort 3"}}
    n1["dim_date[month_start]"]
    n2("[Antal kunder]")
    n3["fact_sales[customer_key]"]
    n4(["gold.fact_sales.customer_key"])
    n5("[Kunder seneste måned]")
    n6("[Seneste hele måned slut]")
    n7["fact_sales[order_date]"]
    n8(["gold.fact_sales.order_date"])
    n9["dim_date"]
    n10["dim_date[date_key]"]
    n11("[Kunder måned farve]")
    n12("[Kunder forrige måned]")
    n13("[Kunder måned label]")
    n1 --> n0
    n2 --> n0
    n3 --> n2
    n4 --> n3
    n5 --> n0
    n6 --> n5
    n7 --> n6
    n8 --> n7
    n9 --> n6
    n10 --> n5
    n9 --> n5
    n11 --> n0
    n12 --> n11
    n10 --> n12
    n9 --> n12
    n13 --> n0
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    class n0 slot
    class n1,n3,n7,n10 col
    class n2,n5,n6,n11,n12,n13 msr
    class n4,n8 src
    class n9 tbl
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_date[date_key]` | Beregnet i dim_date (trin Start) | – |
| `dim_date[month_start]` | Beregnet i dim_date (trin Maanedstart) | dim_date: Beregnet (each Date.StartOfMonth([date_key])) |
| `fact_sales[customer_key]` | gold.fact_sales.customer_key | fact_sales: Navigation (gold.fact_sales) |
| `fact_sales[order_date]` | gold.fact_sales.order_date | fact_sales: Navigation (gold.fact_sales) |

### Søjler pr. kategori

```mermaid
flowchart LR
    n0{{"Søjler pr. kategori"}}
    n1["dim_products[category]"]
    n2(["gold.dim_products.category"])
    n3("[Antal ordrer]")
    n4["fact_sales[order_number]"]
    n5(["gold.fact_sales.order_number"])
    n1 --> n0
    n2 --> n1
    n3 --> n0
    n4 --> n3
    n5 --> n4
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    class n0 slot
    class n1,n4 col
    class n2,n5 src
    class n3 msr
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_products[category]` | gold.dim_products.category | dim_products: Navigation (gold.dim_products) |
| `fact_sales[order_number]` | gold.fact_sales.order_number | fact_sales: Navigation (gold.fact_sales) |

### Top 10-tabel

```mermaid
flowchart LR
    n0{{"Top 10-tabel"}}
    n1["dim_products[product_name]"]
    n2(["gold.dim_products.product_name"])
    n3("[Antal ordrer]")
    n4["fact_sales[order_number]"]
    n5(["gold.fact_sales.order_number"])
    n6("[Omsætning]")
    n7["fact_sales[sales_amount]"]
    n8(["gold.fact_sales.sales_amount"])
    n9("[Margin %]")
    n10("[Dækningsbidrag]")
    n11("[Kostpris]")
    n12["dim_products[cost]"]
    n13(["gold.dim_products.cost"])
    n14["fact_sales[quantity]"]
    n15(["gold.fact_sales.quantity"])
    n16["fact_sales"]
    n1 --> n0
    n2 --> n1
    n3 --> n0
    n4 --> n3
    n5 --> n4
    n6 --> n0
    n7 --> n6
    n8 --> n7
    n9 --> n0
    n10 --> n9
    n11 --> n10
    n12 --> n11
    n13 --> n12
    n14 --> n11
    n15 --> n14
    n16 --> n11
    n4 --> n0
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef tbl fill:#333333,color:#FFFFFF,stroke:#333333
    class n0 slot
    class n1,n4,n7,n12,n14 col
    class n2,n5,n8,n13,n15 src
    class n3,n6,n9,n10,n11 msr
    class n16 tbl
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_products[cost]` | gold.dim_products.cost | dim_products: Navigation (gold.dim_products) |
| `dim_products[product_name]` | gold.dim_products.product_name | dim_products: Navigation (gold.dim_products) |
| `fact_sales[order_number]` | gold.fact_sales.order_number | fact_sales: Navigation (gold.fact_sales) |
| `fact_sales[quantity]` | gold.fact_sales.quantity | fact_sales: Navigation (gold.fact_sales) |
| `fact_sales[sales_amount]` | gold.fact_sales.sales_amount | fact_sales: Navigation (gold.fact_sales) |

### Fremhævning 1

```mermaid
flowchart LR
    n0{{"Fremhævning 1"}}
    n1("[Top underkategori]")
    n2("[Antal ordrer]")
    n3["fact_sales[order_number]"]
    n4(["gold.fact_sales.order_number"])
    n5["dim_products[subcategory]"]
    n6(["gold.dim_products.subcategory"])
    n1 --> n0
    n2 --> n1
    n3 --> n2
    n4 --> n3
    n5 --> n1
    n6 --> n5
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    class n0 slot
    class n1,n2 msr
    class n3,n5 col
    class n4,n6 src
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_products[subcategory]` | gold.dim_products.subcategory | dim_products: Navigation (gold.dim_products) |
| `fact_sales[order_number]` | gold.fact_sales.order_number | fact_sales: Navigation (gold.fact_sales) |

### Fremhævning 2

```mermaid
flowchart LR
    n0{{"Fremhævning 2"}}
    n1("[Top land]")
    n2("[Antal ordrer]")
    n3["fact_sales[order_number]"]
    n4(["gold.fact_sales.order_number"])
    n5["dim_customers[country]"]
    n6(["gold.dim_customers.country"])
    n1 --> n0
    n2 --> n1
    n3 --> n2
    n4 --> n3
    n5 --> n1
    n6 --> n5
    classDef slot fill:#FDEDEF,color:#252423,stroke:#E36C78
    classDef msr fill:#1FC8C0,color:#252423,stroke:#1FC8C0
    classDef col fill:#FFFFFF,color:#252423,stroke:#C8C6C4
    classDef src fill:#252423,color:#FFFFFF,stroke:#252423
    class n0 slot
    class n1,n2 msr
    class n3,n5 col
    class n4,n6 src
```

| Kolonne | Oprindelse | Power Query-trin |
|---|---|---|
| `dim_customers[country]` | gold.dim_customers.country | dim_customers: Navigation (gold.dim_customers) |
| `fact_sales[order_number]` | gold.fact_sales.order_number | fact_sales: Navigation (gold.fact_sales) |

## Kolonne-lineage pr. tabel

<details>
<summary><b>dim_customers</b> (10 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `customer_key` | gold.dim_customers.customer_key | dim_customers: Navigation (gold.dim_customers) |
| `customer_id` | gold.dim_customers.customer_id | dim_customers: Navigation (gold.dim_customers) |
| `customer_number` | gold.dim_customers.customer_number | dim_customers: Navigation (gold.dim_customers) |
| `first_name` | gold.dim_customers.first_name | dim_customers: Navigation (gold.dim_customers) |
| `last_name` | gold.dim_customers.last_name | dim_customers: Navigation (gold.dim_customers) |
| `country` | gold.dim_customers.country | dim_customers: Navigation (gold.dim_customers) |
| `marital_status` | gold.dim_customers.marital_status | dim_customers: Navigation (gold.dim_customers) |
| `gender` | gold.dim_customers.gender | dim_customers: Navigation (gold.dim_customers) |
| `birthdate` | gold.dim_customers.birthdate | dim_customers: Navigation (gold.dim_customers) |
| `create_date` | gold.dim_customers.create_date | dim_customers: Navigation (gold.dim_customers) |

</details>

<details>
<summary><b>dim_date</b> (10 kolonner)</summary>

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
| `day_of_week_no` | Beregnet i dim_date (trin UgedagNr) | dim_date: Beregnet (each Date.DayOfWeek([date_key], Day.Monday) + 1) |
| `day_name` | Beregnet i dim_date (trin Ugedag) | dim_date: Beregnet (each Date.ToText([date_key], [Format = "ddd", Culture = "da…) |

</details>

<details>
<summary><b>dim_products</b> (11 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `product_key` | gold.dim_products.product_key | dim_products: Navigation (gold.dim_products) |
| `product_id` | gold.dim_products.product_id | dim_products: Navigation (gold.dim_products) |
| `product_number` | gold.dim_products.product_number | dim_products: Navigation (gold.dim_products) |
| `product_name` | gold.dim_products.product_name | dim_products: Navigation (gold.dim_products) |
| `category_id` | gold.dim_products.category_id | dim_products: Navigation (gold.dim_products) |
| `category` | gold.dim_products.category | dim_products: Navigation (gold.dim_products) |
| `subcategory` | gold.dim_products.subcategory | dim_products: Navigation (gold.dim_products) |
| `maintenance` | gold.dim_products.maintenance | dim_products: Navigation (gold.dim_products) |
| `cost` | gold.dim_products.cost | dim_products: Navigation (gold.dim_products) |
| `product_line` | gold.dim_products.product_line | dim_products: Navigation (gold.dim_products) |
| `start_date` | gold.dim_products.start_date | dim_products: Navigation (gold.dim_products) |

</details>

<details>
<summary><b>fact_sales</b> (9 kolonner)</summary>

| Kolonne | Oprindelse | Power Query-trin / DAX |
|---|---|---|
| `order_number` | gold.fact_sales.order_number | fact_sales: Navigation (gold.fact_sales) |
| `product_key` | gold.fact_sales.product_key | fact_sales: Navigation (gold.fact_sales) |
| `customer_key` | gold.fact_sales.customer_key | fact_sales: Navigation (gold.fact_sales) |
| `order_date` | gold.fact_sales.order_date | fact_sales: Navigation (gold.fact_sales) |
| `shipping_date` | gold.fact_sales.shipping_date | fact_sales: Navigation (gold.fact_sales) |
| `due_date` | gold.fact_sales.due_date | fact_sales: Navigation (gold.fact_sales) |
| `sales_amount` | gold.fact_sales.sales_amount | fact_sales: Navigation (gold.fact_sales) |
| `quantity` | gold.fact_sales.quantity | fact_sales: Navigation (gold.fact_sales) |
| `price` | gold.fact_sales.price | fact_sales: Navigation (gold.fact_sales) |

</details>
