-- Gold: stjerneskema som TABELLER + load-procedure (i stedet for views som i 03_scripts/gold/ddl_gold.sql).
-- Hvorfor tabeller:
--   * Surrogatnøgler (row_number) fryses pr. load. Power BI henter dim og fakta i separate forespørgsler;
--     med views kan nøglerne flytte sig, hvis silver genindlæses midt i en refresh.
--   * PK/FK-constraints håndhæver gold-testene (unikke nøgler, ingen forældreløse fakta) ved hver load.
--   * Import er hurtig og belaster ikke silver.
-- Joins og kolonnenavne er de samme som i ddl_gold.sql.

create table if not exists gold.dim_customers (
    customer_key    integer primary key,   -- surrogatnøgle
    customer_id     integer not null unique,
    customer_number text,
    first_name      text,
    last_name       text,
    country         text,
    marital_status  text,
    gender          text,
    birthdate       date,
    create_date     date
);

create table if not exists gold.dim_products (
    product_key    integer primary key,    -- surrogatnøgle
    product_id     integer,
    product_number text not null unique,
    product_name   text,
    category_id    text,
    category       text,
    subcategory    text,
    maintenance    text,
    cost           integer,
    product_line   text,
    start_date     date
);

create table if not exists gold.fact_sales (
    order_number  text,
    product_key   integer references gold.dim_products (product_key),
    customer_key  integer references gold.dim_customers (customer_key),
    order_date    date,
    shipping_date date,
    due_date      date,
    sales_amount  integer,
    quantity      integer,
    price         integer
);

create index if not exists fact_sales_product_key_idx  on gold.fact_sales (product_key);
create index if not exists fact_sales_customer_key_idx on gold.fact_sales (customer_key);
create index if not exists fact_sales_order_date_idx   on gold.fact_sales (order_date);

create or replace procedure gold.load_gold()
language plpgsql
as $$
declare
    v_rows bigint;
begin
    truncate table gold.fact_sales, gold.dim_customers, gold.dim_products;

    insert into gold.dim_customers
    select
        row_number() over (order by ci.cst_id) as customer_key,
        ci.cst_id                 as customer_id,
        ci.cst_key                as customer_number,
        ci.cst_firstname          as first_name,
        ci.cst_lastname           as last_name,
        la.cntry                  as country,
        ci.cst_marital_status     as marital_status,
        case
            when ci.cst_gndr != 'n/a' then ci.cst_gndr   -- CRM er primær kilde for køn
            else coalesce(ca.gen, 'n/a')                 -- fallback til ERP
        end                       as gender,
        ca.bdate                  as birthdate,
        ci.cst_create_date        as create_date
    from silver.crm_cust_info ci
    left join silver.erp_cust_az12 ca on ci.cst_key = ca.cid
    left join silver.erp_loc_a101  la on ci.cst_key = la.cid;
    get diagnostics v_rows = row_count;
    raise notice 'gold.dim_customers: % rækker', v_rows;

    insert into gold.dim_products
    select
        row_number() over (order by pn.prd_start_dt, pn.prd_key) as product_key,
        pn.prd_id       as product_id,
        pn.prd_key      as product_number,
        pn.prd_nm       as product_name,
        pn.cat_id       as category_id,
        pc.cat          as category,
        pc.subcat       as subcategory,
        pc.maintenance  as maintenance,
        pn.prd_cost     as cost,
        pn.prd_line     as product_line,
        pn.prd_start_dt as start_date
    from silver.crm_prd_info pn
    left join silver.erp_px_cat_g1v2 pc on pn.cat_id = pc.id
    where pn.prd_end_dt is null;   -- kun aktuelle produkter
    get diagnostics v_rows = row_count;
    raise notice 'gold.dim_products: % rækker', v_rows;

    insert into gold.fact_sales
    select
        sd.sls_ord_num  as order_number,
        pr.product_key  as product_key,
        cu.customer_key as customer_key,
        sd.sls_order_dt as order_date,
        sd.sls_ship_dt  as shipping_date,
        sd.sls_due_dt   as due_date,
        sd.sls_sales    as sales_amount,
        sd.sls_quantity as quantity,
        sd.sls_price    as price
    from silver.crm_sales_details sd
    left join gold.dim_products  pr on sd.sls_prd_key = pr.product_number
    left join gold.dim_customers cu on sd.sls_cust_id = cu.customer_id;
    get diagnostics v_rows = row_count;
    raise notice 'gold.fact_sales: % rækker', v_rows;
end;
$$;

comment on procedure gold.load_gold() is 'Genopbygger gold-stjerneskemaet fra silver (truncate + insert).';
