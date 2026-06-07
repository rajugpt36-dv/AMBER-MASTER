@echo off
set TEST=%1
if "%TEST%"=="" set TEST=tc015_stress_test

echo === Cleaning ===
if exist work rmdir /s /q work
if exist covhtmlreport rmdir /s /q covhtmlreport
vlib work
vmap work work

echo === Compiling for Coverage ===
vlog -sv +cover=bcesf +incdir+../tb/transaction +incdir+../tb/agent +incdir+../tb/sequencer +incdir+../tb/driver +incdir+../tb/monitor +incdir+../tb/scoreboard +incdir+../tb/coverage +incdir+../tb/env +incdir+../tb/sequence +incdir+../tb/test ../interface/axi4lite_if.sv ../rtl/axi4lite_slave_bfm.sv ../tb/axi4lite_assertions.sv ../tb/axi4lite_pkg.sv ../tb/tb_top.sv

if %ERRORLEVEL% neq 0 (
    echo Compilation Failed!
    exit /b %ERRORLEVEL%
)

echo === Running %TEST% with Coverage Enabled ===
vsim -c -coverage -suppress 3009 -t 1ps -do "coverage save -onexit cov.ucdb; run -all; quit" tb_top +UVM_TESTNAME=%TEST%

echo === Generating HTML Report ===
vcover report -html cov.ucdb -htmldir covhtmlreport -details

echo.
echo =======================================================
echo Coverage generation complete! 
echo Open sim\covhtmlreport\index.html in your web browser.
echo =======================================================
