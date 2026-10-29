<#
  Loader de seks CSV-filer til bronze med psql \copy via Supabase-pooleren (session mode, port 5432).
  Tømmer hver bronze-tabel før load (truncate), så scriptet kan køres igen.

  Krav:
    - psql på PATH (fx PostgreSQL 16 client tools)
    - Miljøvariabler: SUPABASE_DB_PASSWORD, SUPABASE_POOLER_HOST og SUPABASE_PROJECT_REF
      (host står under Connect > Session pooler, fx aws-0-<region>.pooler.supabase.com)

  Brug:
    $env:SUPABASE_DB_PASSWORD = '...'      # sættes i sessionen, aldrig i filen
    $env:SUPABASE_POOLER_HOST = 'aws-0-<region>.pooler.supabase.com'
    $env:SUPABASE_PROJECT_REF = '<project-ref>'
    .\scripts\load_bronze.ps1 -DatasetDir 'C:\sti\til\sql-data-warehouse-project\01_datasets'
#>
param(
    [Parameter(Mandatory)] [string] $DatasetDir,
    [string] $ProjectRef = $env:SUPABASE_PROJECT_REF,
    [int]    $Port       = 5432,
    [string] $Database   = 'postgres'
)
$ErrorActionPreference = 'Stop'

if (-not $env:SUPABASE_DB_PASSWORD) { throw 'Miljøvariablen SUPABASE_DB_PASSWORD er ikke sat.' }
if (-not $env:SUPABASE_POOLER_HOST) { throw 'Miljøvariablen SUPABASE_POOLER_HOST er ikke sat.' }
if (-not $ProjectRef) { throw 'Angiv -ProjectRef eller sæt miljøvariablen SUPABASE_PROJECT_REF.' }

$env:PGPASSWORD = $env:SUPABASE_DB_PASSWORD
$env:PGHOST     = $env:SUPABASE_POOLER_HOST
$env:PGPORT     = $Port
$env:PGDATABASE = $Database
$env:PGUSER     = "postgres.$ProjectRef"
$env:PGSSLMODE  = 'require'

$loads = [ordered]@{
    'bronze.crm_cust_info'     = 'source_crm/cust_info.csv'
    'bronze.crm_prd_info'      = 'source_crm/prd_info.csv'
    'bronze.crm_sales_details' = 'source_crm/sales_details.csv'
    'bronze.erp_cust_az12'     = 'source_erp/CUST_AZ12.csv'
    'bronze.erp_loc_a101'      = 'source_erp/LOC_A101.csv'
    'bronze.erp_px_cat_g1v2'   = 'source_erp/PX_CAT_G1V2.csv'
}

try {
    foreach ($table in $loads.Keys) {
        $file = (Resolve-Path (Join-Path $DatasetDir $loads[$table])).Path -replace '\\', '/'
        $csvRows = (Get-Content $file | Measure-Object -Line).Lines - 1   # minus header

        Write-Host ">> $table <- $file"
        & psql -v ON_ERROR_STOP=1 -q `
            -c "truncate table $table;" `
            -c "\copy $table from '$file' with (format csv, header true, encoding 'UTF8')"
        if ($LASTEXITCODE -ne 0) { throw "Load fejlede for $table" }

        $dbRows = [int](& psql -t -A -c "select count(*) from $table;")
        $status = if ($dbRows -eq $csvRows) { 'OK' } else { 'AFVIGER' }
        Write-Host ("   CSV: {0}  DB: {1}  {2}" -f $csvRows, $dbRows, $status)
    }
}
finally {
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}
