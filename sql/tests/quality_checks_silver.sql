-- Port af 04_tests/quality_checks_silver.sql til Postgres.
-- Hver forespørgsel returnerer én række: check, antal fejl (forventet 0) eller distinkte værdier.

-- Rækkeantal (forventet ud fra CSV-profilering 2026-10-27)
select 'silver.crm_cust_info'     as tabel, count(*) as rows, 18484 as forventet from silver.crm_cust_info
union all select 'silver.crm_prd_info',      count(*), 397   from silver.crm_prd_info
union all select 'silver.crm_sales_details', count(*), 60398 from silver.crm_sales_details
union all select 'silver.erp_cust_az12',     count(*), 18484 from silver.erp_cust_az12
union all select 'silver.erp_loc_a101',      count(*), 18484 from silver.erp_loc_a101
union all select 'silver.erp_px_cat_g1v2',   count(*), 37    from silver.erp_px_cat_g1v2;

-- Fejltællinger (forventet 0 overalt)
select 'crm_cust_info: NULL/dublet cst_id' as check_name, count(*) as fejl
from (select cst_id from silver.crm_cust_info group by cst_id having count(*) > 1 or cst_id is null) x
union all
select 'crm_cust_info: mellemrum i cst_key', count(*)
from silver.crm_cust_info where cst_key != trim(cst_key)
union all
select 'crm_cust_info: mellemrum i navne', count(*)
from silver.crm_cust_info where cst_firstname != trim(cst_firstname) or cst_lastname != trim(cst_lastname)
union all
select 'crm_prd_info: NULL/dublet prd_id', count(*)
from (select prd_id from silver.crm_prd_info group by prd_id having count(*) > 1 or prd_id is null) x
union all
select 'crm_prd_info: mellemrum i prd_nm', count(*)
from silver.crm_prd_info where prd_nm != trim(prd_nm)
union all
select 'crm_prd_info: NULL/negativ prd_cost', count(*)
from silver.crm_prd_info where prd_cost < 0 or prd_cost is null
union all
select 'crm_prd_info: slutdato før startdato', count(*)
from silver.crm_prd_info where prd_end_dt < prd_start_dt
union all
select 'bronze.crm_sales_details: ugyldige due-datoer (info, læser bronze)', count(*)
from bronze.crm_sales_details
where sls_due_dt <= 0 or length(sls_due_dt::text) != 8
   or sls_due_dt > 20500101 or sls_due_dt < 19000101
union all
select 'crm_sales_details: ordredato efter afsendelse/forfald', count(*)
from silver.crm_sales_details where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt
union all
select 'crm_sales_details: sales != quantity * price eller NULL/<=0', count(*)
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
   or sls_sales is null or sls_quantity is null or sls_price is null
   or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
union all
select 'erp_cust_az12: fødselsdato uden for 1924-01-01..i dag (info)', count(*)
from silver.erp_cust_az12 where bdate < date '1924-01-01' or bdate > now()
union all
select 'erp_px_cat_g1v2: mellemrum', count(*)
from silver.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance);

-- Standardisering: distinkte værdier
select 'cst_marital_status' as kolonne, string_agg(distinct cst_marital_status, ', ') as vaerdier from silver.crm_cust_info
union all select 'cst_gndr',    string_agg(distinct cst_gndr, ', ')    from silver.crm_cust_info
union all select 'prd_line',    string_agg(distinct prd_line, ', ')    from silver.crm_prd_info
union all select 'gen',         string_agg(distinct gen, ', ')         from silver.erp_cust_az12
union all select 'cntry',       string_agg(distinct cntry, ', ')       from silver.erp_loc_a101
union all select 'maintenance', string_agg(distinct maintenance, ', ') from silver.erp_px_cat_g1v2;
