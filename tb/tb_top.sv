// =============================================================================
// File        : tb_top.sv
// Description : AXI4-Lite UVM Testbench Top-Level
//               - Instantiates interface, slave BFM, assertions module
//               - Drives clock & reset
//               - Sets VIF into uvm_config_db
//               - Calls run_test()
// =============================================================================
`timescale 1ns/1ps

// Import UVM package and include macros
import uvm_pkg::*;
`include "uvm_macros.svh"

// Import the AXI4-Lite UVM package (includes all TB components)
import axi4lite_pkg::*;

module tb_top;

    // =========================================================================
    // Parameters
    // =========================================================================
    parameter int CLK_PERIOD_NS = 10;
    parameter int RESET_CYCLES  = 10;
    parameter int ADDR_WIDTH    = 32;
    parameter int DATA_WIDTH    = 32;

    // =========================================================================
    // Clock & Reset
    // =========================================================================
    logic clk   = 1'b0;
    logic rst_n = 1'b0;

    always #(CLK_PERIOD_NS/2) clk = ~clk;

    // =========================================================================
    // AXI4-Lite Interface Instantiation
    // =========================================================================
    axi4lite_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) axi_if (
        .clk  (clk),
        .rst_n(rst_n)
    );

    // =========================================================================
    // Slave BFM Module Instantiation
    // =========================================================================
    axi4lite_slave_bfm #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH (1024),
        .AW_DELAY  (0),
        .W_DELAY   (0),
        .B_DELAY   (1),
        .AR_DELAY  (0),
        .R_DELAY   (1)
    ) u_slave_bfm (
        .vif(axi_if.slave_mp)
    );

    // =========================================================================
    // SVA Assertions Module Instantiation
    // =========================================================================
    axi4lite_assertions #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MAX_WAIT  (256)
    ) u_assertions (
        .clk     (clk),
        .rst_n   (rst_n),
        .awaddr  (axi_if.awaddr),
        .awvalid (axi_if.awvalid),
        .awready (axi_if.awready),
        .wdata   (axi_if.wdata),
        .wstrb   (axi_if.wstrb),
        .wvalid  (axi_if.wvalid),
        .wready  (axi_if.wready),
        .bresp   (axi_if.bresp),
        .bvalid  (axi_if.bvalid),
        .bready  (axi_if.bready),
        .araddr  (axi_if.araddr),
        .arvalid (axi_if.arvalid),
        .arready (axi_if.arready),
        .rdata   (axi_if.rdata),
        .rresp   (axi_if.rresp),
        .rvalid  (axi_if.rvalid),
        .rready  (axi_if.rready)
    );

    // =========================================================================
    // Clock & Reset Generation
    // =========================================================================
    initial begin
        rst_n = 1'b0;
        repeat(RESET_CYCLES) @(posedge clk);
        rst_n = 1'b1;
        `uvm_info("TB_TOP", "Reset deasserted", UVM_LOW)
    end

    // =========================================================================
    // UVM: Set virtual interface in config_db, then run_test
    // =========================================================================
    initial begin
        // Register VIF at top level for test to retrieve
        uvm_config_db #(virtual axi4lite_if)::set(
            null, "uvm_test_top", "vif", axi_if);

        // Start UVM test (test name from +UVM_TESTNAME plusarg)
        run_test();
    end

    // =========================================================================
    // Waveform Dump
    // =========================================================================
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_top);
    end

    // =========================================================================
    // Simulation Timeout Safety Net
    // =========================================================================
    initial begin
        #(5_000_000ns);  // 5ms absolute timeout
        `uvm_fatal("TB_TOP", "Absolute simulation timeout hit!")
    end

endmodule : tb_top
