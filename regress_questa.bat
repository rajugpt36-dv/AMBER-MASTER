@echo off
setlocal enabledelayedexpansion

echo === Cleaning ===
if exist work rmdir /s /q work
vlib work
vmap work work

echo === Compiling ===
vlog -sv +incdir+../tb/transaction +incdir+../tb/agent +incdir+../tb/sequencer +incdir+../tb/driver +incdir+../tb/monitor +incdir+../tb/scoreboard +incdir+../tb/coverage +incdir+../tb/env +incdir+../tb/sequence +incdir+../tb/test ../interface/axi4lite_if.sv ../rtl/axi4lite_slave_bfm.sv ../tb/axi4lite_assertions.sv ../tb/axi4lite_pkg.sv ../tb/tb_top.sv

if %ERRORLEVEL% neq 0 (
    echo Compilation Failed!
    exit /b %ERRORLEVEL%
)

if not exist logs mkdir logs

set TESTS=tc001_single_write_test tc002_single_read_test tc003_write_read_test tc004_seq_writes_test tc005_seq_reads_test tc006_rand_writes_test tc007_rand_reads_test tc008_rand_mix_test tc009_reset_idle_test tc010_reset_txn_test tc011_b2b_writes_test tc012_b2b_reads_test tc013_wstrb_all_test tc014_invalid_addr_test tc015_stress_test tc016_data_patterns_test

set PASS=0
set FAIL=0

echo.
echo === Starting Regression ===
for %%T in (%TESTS%) do (
    echo | set /p dummy="Running %%T ... "
    vsim -c -suppress 3009 -t 1ps -do "run -all; quit" tb_top +UVM_TESTNAME=%%T -l logs\%%T.log > NUL 2>&1
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
echo ===============================
echo       REGRESSION SUMMARY
echo ===============================
echo   Passed : !PASS!
echo   Failed : !FAIL!
echo ===============================
