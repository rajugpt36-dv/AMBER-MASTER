@echo off
set TEST=%1
if "%TEST%"=="" set TEST=tc011_b2b_writes_test

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

echo === Running %TEST% ===
vsim -c -suppress 3009 -t 1ps -do "run -all; quit" tb_top +UVM_TESTNAME=%TEST%
