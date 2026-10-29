-- Daglig genindlæsning af silver og gold med pg_cron.
-- Tidspunkt: 05:00 UTC = kl. 06 dansk vintertid / kl. 07 sommertid (pg_cron kører i UTC).
-- Bronze fyldes stadig manuelt (scripts/load_bronze.ps1); jobbet bygger silver og gold fra det, der ligger i bronze.
-- Kør hele filen i Supabase SQL Editor.

create extension if not exists pg_cron with schema pg_catalog;

grant usage on schema cron to postgres;

-- Samme navn igen opdaterer jobbet i stedet for at lave et nyt.
select cron.schedule(
    'daily_load_silver_gold',
    '0 5 * * *',
    $$call silver.load_silver(); call gold.load_gold();$$
);

-- Tjek jobbet:
--   select jobid, jobname, schedule, command, active from cron.job;
-- Seneste kørsler:
--   select jobid, status, return_message, start_time, end_time
--   from cron.job_run_details order by start_time desc limit 10;
-- Stop jobbet:
--   select cron.unschedule('daily_load_silver_gold');
