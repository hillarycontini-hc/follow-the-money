#!/usr/bin/env pwsh
# Task runner for follow-the-money.
#
#   ./tasks.ps1 setup     install the pinned toolchain and dbt packages
#   ./tasks.ps1 ingest     pull from Socrata into DuckDB (incremental)
#   ./tasks.ps1 build      run and test the whole dbt project
#   ./tasks.ps1 metrics    query the governed semantic layer
#   ./tasks.ps1 all        setup + ingest + build + metrics
#
# DBT_PROFILES_DIR points at the repo so no ~/.dbt/profiles.yml is needed.

param([Parameter(Position = 0)][string]$Task = "all")

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot
$env:DBT_PROFILES_DIR = $repo
$dbt = Join-Path $repo ".venv\Scripts\dbt.exe"
$mf  = Join-Path $repo ".venv\Scripts\mf.exe"
$py  = Join-Path $repo ".venv\Scripts\python.exe"

function Invoke-Setup {
    Write-Host "==> installing toolchain" -ForegroundColor Cyan
    uv sync
    & $dbt deps
}

function Invoke-Ingest {
    Write-Host "==> ingesting from Socrata" -ForegroundColor Cyan
    & $py (Join-Path $repo "pipelines\socrata_contributions.py")
}

function Invoke-Build {
    Write-Host "==> dbt build" -ForegroundColor Cyan
    & $dbt build
}

function Invoke-Metrics {
    Write-Host "==> governed metrics" -ForegroundColor Cyan
    & $mf query --metrics developer_contributions --group-by metric_time__year
}

switch ($Task.ToLower()) {
    "setup"   { Invoke-Setup }
    "ingest"  { Invoke-Ingest }
    "build"   { Invoke-Build }
    "metrics" { Invoke-Metrics }
    "all"     { Invoke-Setup; Invoke-Ingest; Invoke-Build; Invoke-Metrics }
    default   { Write-Error "unknown task '$Task' (setup|ingest|build|metrics|all)" }
}
