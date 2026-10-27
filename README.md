# Datamodellering

Medallion gold-lag og semantisk model til Power BI (PBIP/TMDL), bygget fra en silver-Excel med Claude Code.

## Indhold

| Mappe / fil | Indhold |
| --- | --- |
| `CLAUDE.md` | Instruktioner til Claude Code (arbejdsgang, stil) |
| `docs/naming_conventions.md` | Navngivningsregler (snake_case, `fact_` / `dim_`, `<navn>_key`) |
| `docs/Guide_datamodellering.pdf` / `.docx` | Guide til fremtidige projekter |
| `data/silver/` | Silver-Excel (kildedata) |
| `diagrams/sales_model.dbml` | Stjerneskema til [dbdiagram.io](https://dbdiagram.io/d) |
| `output/sales_model/` | PBIP-projekt (åbn `sales_model.pbip` i Power BI Desktop) |
| `output/m/` | Power Query M-kode, én fil pr. forespørgsel |

## Modellen `sales_model`

- Fakta: `fact_sales`, `fact_campaign_spend`, `fact_inventory`, `fact_sales_target`
- Dimensioner: `dim_date`, `dim_customer`, `dim_product`, `dim_channel`, `dim_region`, `dim_campaign`
- Koblingstabel: `bridge_campaign_product`
- 27 measures og RLS-rollen `Region`

Ved første åbning: ret parameteren `ExcelSti` til stien til `data/silver/Silver_Excel.xlsx`, og klik **Opdater**.
