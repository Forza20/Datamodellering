-- Rul modelbeslutningerne fra 20261029100000_model_decisions.sql tilbage.
-- Resultat: samme tilstand som før grill-sessionen (procedurer som i 20261027120300/120400).
-- Kør hele filen i Supabase SQL Editor.

alter table gold.fact_sales
    drop column if exists unit_cost,
    drop column if exists order_date_derived;

alter table silver.crm_sales_details
    drop column if exists sls_order_dt_derived;

-- Oprindelige procedurer (kopieret uændret fra 20261027120300 og 20261027120400)
create or replace procedure silver.load_silver()
language plpgsql
as $$
declare
    v_start       timestamptz;
    v_batch_start timestamptz := clock_timestamp();
    v_rows        bigint;
begin
    raise notice 'Loading Silver Layer';

    -- crm_cust_info: trim navne, standardisér status/køn, nyeste række pr. kunde
    v_start := clock_timestamp();
    truncate table silver.crm_cust_info;
    insert into silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname,
        cst_marital_status, cst_gndr, cst_create_date
    )
    select
        cst_id,
        cst_key,
        trim(cst_firstname) as cst_firstname,
        trim(cst_lastname)  as cst_lastname,
        case
            when upper(trim(cst_marital_status)) = 'S' then 'Single'
            when upper(trim(cst_marital_status)) = 'M' then 'Married'
            else 'n/a'
        end as cst_marital_status,
        case
            when upper(trim(cst_gndr)) = 'F' then 'Female'
            when upper(trim(cst_gndr)) = 'M' then 'Male'
            else 'n/a'
        end as cst_gndr,
        cst_create_date
    from (
        select
            *,
            row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
        from bronze.crm_cust_info
        where cst_id is not null
    ) t
    where flag_last = 1;
    get diagnostics v_rows = row_count;
    raise notice 'silver.crm_cust_info: % rækker (% s)', v_rows,
        round(extract(epoch from clock_timestamp() - v_start)::numeric, 2);

    -- crm_prd_info: udled cat_id og prd_key, kostpris 0 ved NULL, produktlinje, slutdato
    v_start := clock_timestamp();
    truncate table silver.crm_prd_info;
    insert into silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm, prd_cost,
        prd_line, prd_start_dt, prd_end_dt
    )
    select
        prd_id,
        replace(substring(prd_key from 1 for 5), '-', '_') as cat_id,
        substring(prd_key from 7)                           as prd_key,
        prd_nm,
        coalesce(prd_cost, 0)                               as prd_cost,
        case
            when upper(trim(prd_line)) = 'M' then 'Mountain'
            when upper(trim(prd_line)) = 'R' then 'Road'
            when upper(trim(prd_line)) = 'S' then 'Other Sales'
            when upper(trim(prd_line)) = 'T' then 'Touring'
            else 'n/a'
        end                                                 as prd_line,
        prd_start_dt::date                                  as prd_start_dt,
        (lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)
            - interval '1 day')::date                       as prd_end_dt
    from bronze.crm_prd_info;
    get diagnostics v_rows = row_count;
    raise notice 'silver.crm_prd_info: % rækker (% s)', v_rows,
        round(extract(epoch from clock_timestamp() - v_start)::numeric, 2);

    -- crm_sales_details: ugyldige datoer -> NULL, genberegn salg og pris
    v_start := clock_timestamp();
    truncate table silver.crm_sales_details;
    insert into silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id,
        sls_order_dt, sls_ship_dt, sls_due_dt,
        sls_sales, sls_quantity, sls_price
    )
    select
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        case
            when sls_order_dt = 0 or length(sls_order_dt::text) != 8 then null
            else sls_order_dt::text::date
        end as sls_order_dt,
        case
            when sls_ship_dt = 0 or length(sls_ship_dt::text) != 8 then null
            else sls_ship_dt::text::date
        end as sls_ship_dt,
        case
            when sls_due_dt = 0 or length(sls_due_dt::text) != 8 then null
            else sls_due_dt::text::date
        end as sls_due_dt,
        case
            when sls_sales is null or sls_sales <= 0
                 or sls_sales != sls_quantity * abs(sls_price)
                then sls_quantity * abs(sls_price)
            else sls_sales
        end as sls_sales,
        sls_quantity,
        case
            when sls_price is null or sls_price <= 0
                then sls_sales / nullif(sls_quantity, 0)   -- heltalsdivision som i T-SQL
            else sls_price
        end as sls_price
    from bronze.crm_sales_details;
    get diagnostics v_rows = row_count;
    raise notice 'silver.crm_sales_details: % rækker (% s)', v_rows,
        round(extract(epoch from clock_timestamp() - v_start)::numeric, 2);

    -- erp_cust_az12: fjern 'NAS'-prefix, fremtidige fødselsdatoer -> NULL, standardisér køn
    v_start := clock_timestamp();
    truncate table silver.erp_cust_az12;
    insert into silver.erp_cust_az12 (cid, bdate, gen)
    select
        case
            when cid like 'NAS%' then substring(cid from 4)
            else cid
        end as cid,
        case
            when bdate > now() then null
            else bdate
        end as bdate,
        case
            when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
            when upper(trim(gen)) in ('M', 'MALE')   then 'Male'
            else 'n/a'
        end as gen
    from bronze.erp_cust_az12;
    get diagnostics v_rows = row_count;
    raise notice 'silver.erp_cust_az12: % rækker (% s)', v_rows,
        round(extract(epoch from clock_timestamp() - v_start)::numeric, 2);

    -- erp_loc_a101: fjern '-' i cid, standardisér landenavne
    v_start := clock_timestamp();
    truncate table silver.erp_loc_a101;
    insert into silver.erp_loc_a101 (cid, cntry)
    select
        replace(cid, '-', '') as cid,
        case
            when trim(cntry) = 'DE'              then 'Germany'
            when trim(cntry) in ('US', 'USA')    then 'United States'
            when trim(cntry) = '' or cntry is null then 'n/a'
            else trim(cntry)
        end as cntry
    from bronze.erp_loc_a101;
    get diagnostics v_rows = row_count;
    raise notice 'silver.erp_loc_a101: % rækker (% s)', v_rows,
        round(extract(epoch from clock_timestamp() - v_start)::numeric, 2);

    -- erp_px_cat_g1v2: 1:1
    v_start := clock_timestamp();
    truncate table silver.erp_px_cat_g1v2;
    insert into silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    select id, cat, subcat, maintenance
    from bronze.erp_px_cat_g1v2;
    get diagnostics v_rows = row_count;
    raise notice 'silver.erp_px_cat_g1v2: % rækker (% s)', v_rows,
        round(extract(epoch from clock_timestamp() - v_start)::numeric, 2);

    raise notice 'Silver færdig på % s',
        round(extract(epoch from clock_timestamp() - v_batch_start)::numeric, 2);
exception
    when others then
        raise notice 'FEJL under load af silver: % (SQLSTATE %)', sqlerrm, sqlstate;
        raise;
end;
$$;

comment on procedure silver.load_silver() is 'Loader silver fra bronze (truncate + insert). Port af proc_load_silver.sql.';

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

-- Som i 20261028090000_powerbi_reader_access.sql
alter procedure silver.load_silver() set search_path = '';
alter procedure gold.load_gold()     set search_path = '';

-- Genindlæs med de gamle regler
call silver.load_silver();
call gold.load_gold();