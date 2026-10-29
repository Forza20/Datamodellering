-- Port af 04_tests/quality_checks_gold.sql til Postgres. Forventet 0 fejl overalt.

select 'gold.dim_customers' as tabel, count(*) as rows from gold.dim_customers
union all select 'gold.dim_products', count(*) from gold.dim_products
union all select 'gold.fact_sales',   count(*) from gold.fact_sales;

select 'dim_customers: dublet customer_key' as check_name, count(*) as fejl
from (select customer_key from gold.dim_customers group by customer_key having count(*) > 1) x
union all
select 'dim_customers: dublet customer_id', count(*)
from (select customer_id from gold.dim_customers group by customer_id having count(*) > 1) x
union all
select 'dim_products: dublet product_key', count(*)
from (select product_key from gold.dim_products group by product_key having count(*) > 1) x
union all
select 'dim_products: dublet product_number', count(*)
from (select product_number from gold.dim_products group by product_number having count(*) > 1) x
union all
select 'fact_sales: forældreløs/NULL customer_key', count(*)
from gold.fact_sales f
left join gold.dim_customers c on c.customer_key = f.customer_key
where c.customer_key is null
union all
select 'fact_sales: forældreløs/NULL product_key', count(*)
from gold.fact_sales f
left join gold.dim_products p on p.product_key = f.product_key
where p.product_key is null
union all
select 'fact_sales: NULL order_date (forventet 0 efter afledning, R2-2)', count(*)
from gold.fact_sales where order_date is null
union all
select 'fact_sales: NULL unit_cost (forventet 0, R2-1)', count(*)
from gold.fact_sales where unit_cost is null;

-- Informations-tjek (ikke fejl, men skal kendes – se docs/model-decisions.md)
select 'info: afledte ordredatoer (R2-2)' as check_name, count(*) as raekker
from gold.fact_sales where order_date_derived
union all
select 'info: køn forskelligt i CRM og ERP – CRM vinder (R2-3)', count(*)
from silver.crm_cust_info c
join silver.erp_cust_az12 e on e.cid = c.cst_key
where c.cst_gndr <> 'n/a' and e.gen <> 'n/a' and c.cst_gndr <> e.gen
union all
select 'info: salgslinjer hvor kostpris på ordredato <> nuværende kostpris (R2-1)', count(*)
from gold.fact_sales f join gold.dim_products p using (product_key)
where f.unit_cost <> p.cost;
