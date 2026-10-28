-- Bronze: én tabel pr. CSV-fil. Kolonner i samme rækkefølge som CSV-headeren.
-- Datatyper følger 03_scripts/bronze/ddl_bronze.sql (NVARCHAR -> text, DATETIME -> timestamp).
-- Ingen DROP: create table if not exists, så eksisterende tabeller ikke overskrives.

-- 01_datasets/source_crm/cust_info.csv
create table if not exists bronze.crm_cust_info (
    cst_id             integer,
    cst_key            text,
    cst_firstname      text,
    cst_lastname       text,
    cst_marital_status text,
    cst_gndr           text,
    cst_create_date    date
);

-- 01_datasets/source_crm/prd_info.csv
create table if not exists bronze.crm_prd_info (
    prd_id       integer,
    prd_key      text,
    prd_nm       text,
    prd_cost     integer,
    prd_line     text,
    prd_start_dt timestamp,
    prd_end_dt   timestamp
);

-- 01_datasets/source_crm/sales_details.csv (datoer er heltal i formatet yyyymmdd)
create table if not exists bronze.crm_sales_details (
    sls_ord_num  text,
    sls_prd_key  text,
    sls_cust_id  integer,
    sls_order_dt integer,
    sls_ship_dt  integer,
    sls_due_dt   integer,
    sls_sales    integer,
    sls_quantity integer,
    sls_price    integer
);

-- 01_datasets/source_erp/LOC_A101.csv
create table if not exists bronze.erp_loc_a101 (
    cid   text,
    cntry text
);

-- 01_datasets/source_erp/CUST_AZ12.csv
create table if not exists bronze.erp_cust_az12 (
    cid   text,
    bdate date,
    gen   text
);

-- 01_datasets/source_erp/PX_CAT_G1V2.csv
create table if not exists bronze.erp_px_cat_g1v2 (
    id          text,
    cat         text,
    subcat      text,
    maintenance text
);
