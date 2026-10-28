-- Opretter de tre lag i medallion-arkitekturen.
-- Port af 03_scripts/init_database.sql (database-drop er udeladt: Supabase-databasen genbruges).
create schema if not exists bronze;
create schema if not exists silver;
create schema if not exists gold;

comment on schema bronze is 'Rå data fra CSV-kilderne (CRM og ERP). Ingen transformation.';
comment on schema silver is 'Renset og standardiseret data.';
comment on schema gold   is 'Stjerneskema til rapportering (Power BI).';
