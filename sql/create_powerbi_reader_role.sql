-- Read-only rolle til Power BI: kun SELECT på schemaet gold.
-- Køres af dig (som postgres) i Supabase SQL Editor. Password sættes bagefter af dig selv (se nederst).

create role powerbi_reader
    login
    nosuperuser nocreatedb nocreaterole noinherit
    connection limit 10;

-- Altid read-only, også hvis nogen glemmer en grant
alter role powerbi_reader set default_transaction_read_only = on;

-- Adgang til gold og intet andet
grant usage  on schema gold to powerbi_reader;
grant select on all tables in schema gold to powerbi_reader;

-- Nye tabeller/views i gold, oprettet af postgres, bliver også læsbare
alter default privileges for role postgres in schema gold
    grant select on tables to powerbi_reader;

-- Sæt password (kør selv, med dit eget password – gem det ikke i repoet):
--   alter role powerbi_reader with password '<dit-password>';
-- eller i psql:  \password powerbi_reader
--
-- Pooler-login i Power BI: brugernavn = powerbi_reader.spihvuokluprvafmchvn

-- Kontrol (forventet: kun gold-tabeller med SELECT):
-- select table_schema, table_name, privilege_type
-- from information_schema.role_table_grants
-- where grantee = 'powerbi_reader'
-- order by 1, 2;
