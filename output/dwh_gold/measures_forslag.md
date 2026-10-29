# Measures – forslag til dwh_gold

Status: **tilføjet modellen** i tabellen `_Measures` (`tables/_Measures.tmdl`), 17 measures.

## Konventioner

- Navne på dansk, i samme stil som `sales_model` (fx `Omsætning`, `Antal ordrer`).
- Afledte measures har basisnavnet først: `Omsætning YTD`, `Omsætning YoY %`.
- Alle divisioner med `DIVIDE`. Variabler (`VAR`) hvor et udtryk bruges mere end én gang.
- Time intelligence bruger `dim_date[date_key]` (markeret datotabel, relation til `fact_sales[order_date]`).
- Display folders: `Salg`, `Kunder`, `Tidsintelligens`, `Rangering`.

## Salg

| Measure | DAX | Format | Folder |
|---|---|---|---|
| Omsætning | `SUM ( fact_sales[sales_amount] )` | `#,##0` | Salg |
| Antal ordrer | `DISTINCTCOUNT ( fact_sales[order_number] )` | `#,##0` | Salg |
| Antal ordrelinjer | `COUNTROWS ( fact_sales )` | `#,##0` | Salg |
| Antal enheder | `SUM ( fact_sales[quantity] )` | `#,##0` | Salg |
| Gns. ordrelinje | `DIVIDE ( [Omsætning], [Antal ordrelinjer] )` | `#,##0.00` | Salg |
| Gns. ordreværdi | `DIVIDE ( [Omsætning], [Antal ordrer] )` | `#,##0.00` | Salg |

## Kunder

| Measure | DAX | Format | Folder |
|---|---|---|---|
| Antal kunder | `DISTINCTCOUNT ( fact_sales[customer_key] )` | `#,##0` | Kunder |
| Omsætning pr. kunde | `DIVIDE ( [Omsætning], [Antal kunder] )` | `#,##0.00` | Kunder |

`Antal kunder` tæller kunder **med salg** i den aktuelle filterkontekst. Kunder i alt = `COUNTROWS ( dim_customers )`, hvis I også vil have den.

## Tidsintelligens (indbyggede funktioner)

```dax
Omsætning YTD =
TOTALYTD ( [Omsætning], dim_date[date_key] )

Omsætning sidste år =
CALCULATE ( [Omsætning], SAMEPERIODLASTYEAR ( dim_date[date_key] ) )

Omsætning YoY =
VAR _aar = [Omsætning]
VAR _sidsteAar = [Omsætning sidste år]
RETURN
    IF ( NOT ISBLANK ( _aar ) && NOT ISBLANK ( _sidsteAar ), _aar - _sidsteAar )

Omsætning YoY % =
VAR _sidsteAar = [Omsætning sidste år]
RETURN
    DIVIDE ( [Omsætning] - _sidsteAar, _sidsteAar )

Omsætning YTD sidste år =
CALCULATE ( [Omsætning YTD], SAMEPERIODLASTYEAR ( dim_date[date_key] ) )

Omsætning YTD YoY % =
VAR _ytd = [Omsætning YTD]
VAR _ytdSidsteAar = [Omsætning YTD sidste år]
RETURN
    DIVIDE ( _ytd - _ytdSidsteAar, _ytdSidsteAar )
```

Formater: beløb `#,##0`, procenter `0.0 %`. Samme mønster kan bruges til `Antal ordrer` og `Antal enheder`, hvis I ønsker det.

## Rangering: top/bund-produkter

```dax
Produktrang =
IF (
    ISINSCOPE ( dim_products[product_name] ),
    RANKX (
        ALLSELECTED ( dim_products[product_name] ),
        [Omsætning],
        ,
        DESC,
        DENSE
    )
)

Omsætning top 10 produkter =
VAR _top =
    TOPN ( 10, ALLSELECTED ( dim_products[product_name] ), [Omsætning], DESC )
RETURN
    CALCULATE ( [Omsætning], KEEPFILTERS ( _top ) )

Omsætning bund 10 produkter =
VAR _medSalg =
    FILTER ( ALLSELECTED ( dim_products[product_name] ), NOT ISBLANK ( [Omsætning] ) )
VAR _bund =
    TOPN ( 10, _medSalg, [Omsætning], ASC )
RETURN
    CALCULATE ( [Omsætning], KEEPFILTERS ( _bund ) )
```

- `Produktrang` (format `0`) kan bruges som visual-filter (`<= 10`).
- Bund 10 udelader produkter uden salg; ellers ville de 0-sælgende fylde hele listen.
- Ved uafgjort kan TOPN returnere mere end 10 rækker.

## Opmærksomhed

- 19 ordrelinjer har ugyldig ordredato i kilden og får `order_date = NULL`. De tæller med i totaler, men ikke i tidsintelligens.
- Overvej inaktive relationer `fact_sales[shipping_date]` og `fact_sales[due_date]` → `dim_date[date_key]` til `USERELATIONSHIP`-measures (fx `Omsætning efter afsendelsesdato`). Ikke lagt ind.
