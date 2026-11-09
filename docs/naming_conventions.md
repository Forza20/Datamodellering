# Navngivningskonventioner

## Tabeller
- `snake_case` til alle tabeller.
- Faktatabeller: prefix `fact_`, fx `fact_sales`.
- Dimensioner: prefix `dim_` og ental, fx `dim_date`, `dim_customer`. Undtagelse: `dwh_gold` bruger flertal (`dim_customers`) og omdøbes ikke.

## Kolonner
- `snake_case` til alle kolonner.
- Surrogatnøgler hedder `<navn>_key`, fx `customer_key`, `date_key`.
- Fremmednøgler i fakta har samme navn som PK i dimensionen. Undtagelse: rolle-datoer (fx `order_date`, `ship_date`) peger på `dim_date[date_key]`.
- Forretningsnøgler fra kilden beholder deres navn i snake_case, fx `customer_id`.
