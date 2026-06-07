// =============================================================================
// File        : filelist.f
// Description : Cadence Xcelium UVM Compilation Filelist
//               Compile order: interface -> RTL -> UVM pkg -> tb_top
// Usage       : xrun -f filelist.f +UVM_TESTNAME=tc008_rand_mix_test
// =============================================================================

// ---- Simulator Flags --------------------------------------------------------
-sv
-uvm
-uvmhome CDNS-1.2
-access +rwc
-timescale 1ns/1ps
-l xrun.log
-coverage all
-covfile cov.ccf

// ---- UVM verbosity (override per run if needed) ----------------------------
+UVM_VERBOSITY=UVM_MEDIUM

// ---- Interface --------------------------------------------------------------
../interface/axi4lite_if.sv

// ---- RTL (Slave BFM as module) ----------------------------------------------
../rtl/axi4lite_slave_bfm.sv

// ---- Assertions Module ------------------------------------------------------
../tb/axi4lite_assertions.sv

// ---- UVM Transaction (seq item) - included via package ---------------------
-incdir ../tb/transaction
-incdir ../tb/agent
-incdir ../tb/sequencer
-incdir ../tb/driver
-incdir ../tb/monitor
-incdir ../tb/scoreboard
-incdir ../tb/coverage
-incdir ../tb/env
-incdir ../tb/sequence
-incdir ../tb/test

// ---- UVM Package (bundles everything) ---------------------------------------
../tb/axi4lite_pkg.sv

// ---- Top-level testbench ----------------------------------------------------
../tb/tb_top.sv
