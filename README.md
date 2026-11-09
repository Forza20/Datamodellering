# Datamodellering

Medallion gold-lag og semantisk model til Power BI (PBIP/TMDL), bygget med Claude Code: `sales_model` fra en silver-Excel og `dwh_gold` fra Supabase.

## Indhold

| Mappe / fil | Indhold |
| --- | --- |
| `CLAUDE.md` | Instruktioner til Claude Code (arbejdsgang, stil) |
| `docs/naming_conventions.md` | Navngivningsregler (snake_case, `fact_` / `dim_`, `<navn>_key`) |
| `docs/Guide_datamodellering.pdf` / `.docx` | Guide til fremtidige projekter |
| `data/silver/` | Silver-Excel (kildedata) |
| `diagrams/sales_model.dbml`, `diagrams/dwh_gold.dbml` | Stjerneskemaer til [dbdiagram.io](https://dbdiagram.io/d) og [dbdocs](https://dbdocs.io) |
| `output/sales_model/` | PBIP-projekt (åbn `sales_model.pbip` i Power BI Desktop) |
| `output/<model>/docs/` | Data catalog (`catalog.xlsx`), lineage (`lineage.md`, `lineage.azdo.md`) og `model.dbml` |
| `output/m/` | Power Query M-kode, én fil pr. forespørgsel |
| `output/dwh_gold/` | PBIP-projekt `dwh_gold` |
| `supabase/migrations/` | bronze/silver/gold-skemaer og daglig load |
| `sql/tests/` | kvalitetstjek af silver og gold |
| `scripts/load_bronze.ps1` | CSV til bronze via psql |
| `docs/Guide_dwh_gold.md` / `docs/Guide_dwh_gold_en.md` | Guide til dwh_gold (dansk/engelsk) |
| `docs/Guide_brug_af_projektet.pdf` | Guide til brug af projektet |

## Online dokumentation (dbdocs)

| Model | Link |
| --- | --- |
| `sales_model` | https://dbdocs.io/peter-bekker/sales_model |
| `dwh_gold` | https://dbdocs.io/peter-bekker/dwh_gold |

Siderne bygges fra `output/<model>/docs/model.dbml` (genereret med beskrivelser, measures og lineage). Opdatér dem efter en ny generering:

```
npx dbdocs build output/sales_model/docs/model.dbml --project sales_model --public
npx dbdocs build output/dwh_gold/docs/model.dbml --project dwh_gold --public
```

Kræver miljøvariablen `DBDOCS_TOKEN` (lav den med `npx dbdocs token -g`).

## Modellen `sales_model`

- Fakta: `fact_sales`, `fact_campaign_spend`, `fact_inventory`, `fact_sales_target`
- Dimensioner: `dim_date`, `dim_customer`, `dim_product`, `dim_channel`, `dim_region`, `dim_campaign`
- Koblingstabel: `bridge_campaign_product`
- 27 measures og RLS-rollen `Region`

Ved første åbning: ret parameteren `ExcelSti` til stien til `data/silver/Silver_Excel.xlsx`, og klik **Opdater**.
