-- Silver-tabeller. Port af 03_scripts/silver/ddl_silver.sql.
-- NVARCHAR -> text, DATETIME2 DEFAULT GETDATE() -> timestamptz default now().

create table if not exists silver.crm_cust_info (
    cst_id             integer,
    cst_key            text,
    cst_firstname      text,
    cst_lastname       text,
    cst_marital_status text,
    cst_gndr           text,
    cst_create_date    date,
    dwh_create_date    timestamptz default now()
);

create table if not exists silver.crm_prd_info (
    prd_id          integer,
    cat_id          text,
    prd_key         text,
    prd_nm          text,
    prd_cost        integer,
    prd_line        text,
    prd_start_dt    date,
    prd_end_dt      date,
    dwh_create_date timestamptz default now()
);

create table if not exists silver.crm_sales_details (
    sls_ord_num     text,
    sls_prd_key     text,
    sls_cust_id     integer,
    sls_order_dt    date,
    sls_ship_dt     date,
    sls_due_dt      date,
    sls_sales       integer,
    sls_quantity    integer,
    sls_price       integer,
    dwh_create_date timestamptz default now()
);

create table if not exists silver.erp_loc_a101 (
    cid             text,
    cntry           text,
    dwh_create_date timestamptz default now()
);

create table if not exists silver.erp_cust_az12 (
    cid             text,
    bdate           date,
    gen             text,
    dwh_create_date timestamptz default now()
);

create table if not exists silver.erp_px_cat_g1v2 (
    id              text,
    cat             text,
    subcat          text,
    maintenance     text,
    dwh_create_date timestamptz default now()
);
