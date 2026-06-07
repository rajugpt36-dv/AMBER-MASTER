@echo off
setlocal enabledelayedexpansion

echo === Cleaning ===
if exist work rmdir /s /q work
if exist coverage_db rmdir /s /q coverage_db
if exist merged_covhtmlreport rmdir /s /q merged_covhtmlreport
if exist logs rmdir /s /q logs

vlib work
vmap work work
mkdir logs
mkdir coverage_db

echo === Compiling for Coverage ===
vlog -sv +cover=bcesf +incdir+../tb/transaction +incdir+../tb/agent +incdir+../tb/sequencer +incdir+../tb/driver +incdir+../tb/monitor +incdir+../tb/scoreboard +incdir+../tb/coverage +incdir+../tb/env +incdir+../tb/sequence +incdir+../tb/test ../interface/axi4lite_if.sv ../rtl/axi4lite_slave_bfm.sv ../tb/axi4lite_assertions.sv ../tb/axi4lite_pkg.sv ../tb/tb_top.sv

if %ERRORLEVEL% neq 0 (
    echo Compilation Failed!
    exit /b %ERRORLEVEL%
)

set TESTS=tc001_single_write_test tc002_single_read_test tc003_write_read_test tc004_seq_writes_test tc005_seq_reads_test tc006_rand_writes_test tc007_rand_reads_test tc008_rand_mix_test tc009_reset_idle_test tc010_reset_txn_test tc011_b2b_writes_test tc012_b2b_reads_test tc013_wstrb_all_test tc014_invalid_addr_test tc015_stress_test tc016_data_patterns_test

set PASS=0
set FAIL=0

echo.
echo === Starting Coverage Regression ===
for %%T in (%TESTS%) do (
    echo | set /p dummy="Running %%T ... "
    vsim -c -coverage -suppress 3009 -t 1ps -do "coverage save -onexit coverage_db/%%T.ucdb; run -all; quit" tb_top +UVM_TESTNAME=%%T -l logs\%%T.log > NUL 2>&1
    findstr "TEST PASSED" logs\%%T.log > NUL
    if !ERRORLEVEL! equ 0 (
        echo [PASS]
        set /a PASS+=1
    ) else (
        echo [FAIL]
        set /a FAIL+=1
    )
)

echo.
echo === Merging Coverage Databases ===
echo === Merging Coverage Databases and Generating Report ===
python -c "import os, subprocess; ucdbs = ['coverage_db/' + x for x in os.listdir('coverage_db') if x.endswith('.ucdb') and not x == 'merged_coverage.ucdb']; subprocess.run(['vcover', 'merge', 'coverage_db/merged_coverage.ucdb'] + ucdbs); subprocess.run(['vcover', 'report', '-html', 'coverage_db/merged_coverage.ucdb', '-htmldir', 'merged_covhtmlreport', '-details'])"



echo.
echo ===============================
echo       REGRESSION SUMMARY
echo ===============================
echo   Passed : !PASS!
echo   Failed : !FAIL!
echo ===============================
echo   MERGED COVERAGE COMPLETE!
echo   Open sim\merged_covhtmlreport\index.html
echo ===============================
