# Datamodellering

Medallion gold-lag + semantisk model til Power BI (PBIP/TMDL). To modeller: `sales_model` (silver-Excel, Power Query) og `dwh_gold` (Supabase bronze/silver/gold).

## Arbejdsgang
- "Data modeling:" starter skillen data-modeling. Den styrer afklaring, stjerneskema og guide.
- Gem DBML i `diagrams/<model>.dbml`.

## Navngivning
@docs/naming_conventions.md

## Kort
- `README.md`: mappeoversigt og dbdocs-links
- `data/silver/Silver_Excel.xlsx`: silver-kildedata
- `docs/Guide_datamodellering.pdf`: guiden
- `docs/Guide_dwh_gold.md`: dwh_gold trin for trin
- `output/<model>/`: PBIP-projekter, catalog og lineage
- `supabase/migrations/`, `sql/tests/`, `scripts/`: dwh_gold-databasen
- Eksempel på færdig PBIP: `project_datamodel_pbip.zip`

## Stil
Korte danske punkter. Spørg hellere end at gætte ved risikable eller irreversible skridt. I beslutningsinterviews gælder den globale regel: vælg anbefalingen og log den.
