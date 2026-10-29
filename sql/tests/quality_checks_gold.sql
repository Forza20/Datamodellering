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
select 'fact_sales: NULL order_date (info: ugyldige kildedatoer)', count(*)
from gold.fact_sales where order_date is null;
