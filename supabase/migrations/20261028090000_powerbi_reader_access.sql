-- Power BI-adgang til gold + sikkerhedsrettelser fra Supabase advisors.
-- Kan køres igen uden fejl.

-- 1) Read-only rolle (oprettes kun, hvis den mangler). Password sættes manuelt, aldrig her:
--      alter role powerbi_reader with password '<dit-password>';
do $$
begin
    if not exists (select 1 from pg_roles where rolname = 'powerbi_reader') then
        create role powerbi_reader login nosuperuser nocreatedb nocreaterole noinherit connection limit 10;
    end if;
end
$$;

alter role powerbi_reader set default_transaction_read_only = on;

grant usage  on schema gold to powerbi_reader;
grant select on all tables in schema gold to powerbi_reader;
alter default privileges for role postgres in schema gold
    grant select on tables to powerbi_reader;

-- 2) RLS er slået til på gold uden policies -> alle andre end ejeren ser 0 rækker.
--    Læse-policy kun for powerbi_reader.
drop policy if exists powerbi_reader_select on gold.dim_customers;
drop policy if exists powerbi_reader_select on gold.dim_products;
drop policy if exists powerbi_reader_select on gold.fact_sales;

create policy powerbi_reader_select on gold.dim_customers for select to powerbi_reader using (true);
create policy powerbi_reader_select on gold.dim_products  for select to powerbi_reader using (true);
create policy powerbi_reader_select on gold.fact_sales    for select to powerbi_reader using (true);

-- 3) Fast search_path på load-procedurerne (alle tabelnavne er skema-kvalificerede).
alter procedure silver.load_silver() set search_path = '';
alter procedure gold.load_gold()     set search_path = '';
