# Navngivningskonventioner

## Tabeller
- `snake_case` til alle tabeller.
- Faktatabeller: prefix `fact_`, fx `fact_sales`.
- Dimensioner: prefix `dim_`, fx `dim_date`, `dim_customer`.

## Kolonner
- `snake_case` til alle kolonner.
- Surrogatnøgler hedder `<navn>_key`, fx `customer_key`, `date_key`.
- Fremmednøgler i fakta har samme navn som PK i dimensionen.
- Forretningsnøgler fra kilden beholder deres navn i snake_case, fx `customer_id`.
