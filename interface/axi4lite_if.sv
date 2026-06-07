// =============================================================================
// File        : axi4lite_if.sv
// Description : AXI4-Lite Interface with Clocking Blocks and Modports
// =============================================================================
interface axi4lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst_n
);
    // Write Address Channel
    logic [ADDR_WIDTH-1:0]   awaddr;
    logic                    awvalid;
    logic                    awready;
    // Write Data Channel
    logic [DATA_WIDTH-1:0]   wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                    wvalid;
    logic                    wready;
    // Write Response Channel
    logic [1:0]              bresp;
    logic                    bvalid;
    logic                    bready;
    // Read Address Channel
    logic [ADDR_WIDTH-1:0]   araddr;
    logic                    arvalid;
    logic                    arready;
    // Read Data Channel
    logic [DATA_WIDTH-1:0]   rdata;
    logic [1:0]              rresp;
    logic                    rvalid;
    logic                    rready;

    // =========================================================================
    // Master Clocking Block
    // =========================================================================
    clocking master_cb @(posedge clk);
        default input #1step output #1;
        output awaddr, awvalid;
        input  awready;
        output wdata, wstrb, wvalid;
        input  wready;
        input  bresp, bvalid;
        output bready;
        output araddr, arvalid;
        input  arready;
        input  rdata, rresp, rvalid;
        output rready;
    endclocking

    // =========================================================================
    // Slave Clocking Block
    // =========================================================================
    clocking slave_cb @(posedge clk);
        default input #1step output #1;
        input  awaddr, awvalid;
        output awready;
        input  wdata, wstrb, wvalid;
        output wready;
        output bresp, bvalid;
        input  bready;
        input  araddr, arvalid;
        output arready;
        output rdata, rresp, rvalid;
        input  rready;
    endclocking

    // =========================================================================
    // Monitor Clocking Block
    // =========================================================================
    clocking monitor_cb @(posedge clk);
        default input #1step;
        input awaddr, awvalid, awready;
        input wdata, wstrb, wvalid, wready;
        input bresp, bvalid, bready;
        input araddr, arvalid, arready;
        input rdata, rresp, rvalid, rready;
    endclocking

    // =========================================================================
    // Modports
    // =========================================================================
    modport master_mp  (clocking master_cb,  input clk, input rst_n);
    modport slave_mp   (clocking slave_cb,   input clk, input rst_n);
    modport monitor_mp (clocking monitor_cb, input clk, input rst_n);

endinterface : axi4lite_if
