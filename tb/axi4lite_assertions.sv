// =============================================================================
// File        : axi4lite_assertions.sv
// Description : AXI4-Lite Protocol SVA Assertions (standalone module)
//               Bound at tb_top level, checks all 5 AXI4-Lite channels + reset.
// =============================================================================
`ifndef AXI4LITE_ASSERTIONS_SV
`define AXI4LITE_ASSERTIONS_SV

module axi4lite_assertions #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MAX_WAIT   = 256
)(
    input logic clk,
    input logic rst_n,
    // Write Address Channel
    input logic [ADDR_WIDTH-1:0]   awaddr,
    input logic                    awvalid,
    input logic                    awready,
    // Write Data Channel
    input logic [DATA_WIDTH-1:0]   wdata,
    input logic [DATA_WIDTH/8-1:0] wstrb,
    input logic                    wvalid,
    input logic                    wready,
    // Write Response Channel
    input logic [1:0]              bresp,
    input logic                    bvalid,
    input logic                    bready,
    // Read Address Channel
    input logic [ADDR_WIDTH-1:0]   araddr,
    input logic                    arvalid,
    input logic                    arready,
    // Read Data Channel
    input logic [DATA_WIDTH-1:0]   rdata,
    input logic [1:0]              rresp,
    input logic                    rvalid,
    input logic                    rready
);

    default clocking cb @(posedge clk); endclocking
    default disable iff (!rst_n);

    // =========================================================================
    // WRITE ADDRESS CHANNEL
    // =========================================================================
    property p_awvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (awvalid && !awready) |=> awvalid;
    endproperty
    AST_AW01_AWVALID_STABLE: assert property(p_awvalid_stable)
        else $error("[%0t][ASSERT FAIL] AW01: AWVALID dropped before AWREADY", $time);

    property p_awaddr_stable;
        @(posedge clk) disable iff (!rst_n)
        (awvalid && !awready) |=> $stable(awaddr);
    endproperty
    AST_AW02_AWADDR_STABLE: assert property(p_awaddr_stable)
        else $error("[%0t][ASSERT FAIL] AW02: AWADDR changed while AWVALID high", $time);

    property p_awready_within_limit;
        @(posedge clk) disable iff (!rst_n)
        awvalid |-> ##[1:MAX_WAIT] awready;
    endproperty
    AST_AW03_AWREADY_TIMEOUT: assert property(p_awready_within_limit)
        else $error("[%0t][ASSERT FAIL] AW03: AWREADY timeout > %0d cycles", $time, MAX_WAIT);

    property p_awaddr_aligned;
        @(posedge clk) disable iff (!rst_n)
        awvalid |-> (awaddr[1:0] == 2'b00);
    endproperty
    AST_AW04_AWADDR_ALIGNED: assert property(p_awaddr_aligned)
        else $error("[%0t][ASSERT FAIL] AW04: AWADDR=0x%08h not word-aligned", $time, awaddr);

    property p_awaddr_no_x;
        @(posedge clk) disable iff (!rst_n)
        awvalid |-> !$isunknown(awaddr);
    endproperty
    AST_AW05_AWADDR_NO_X: assert property(p_awaddr_no_x)
        else $error("[%0t][ASSERT FAIL] AW05: X/Z on AWADDR during transfer", $time);

    // =========================================================================
    // WRITE DATA CHANNEL
    // =========================================================================
    property p_wvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (wvalid && !wready) |=> wvalid;
    endproperty
    AST_W01_WVALID_STABLE: assert property(p_wvalid_stable)
        else $error("[%0t][ASSERT FAIL] W01: WVALID dropped before WREADY", $time);

    property p_wdata_stable;
        @(posedge clk) disable iff (!rst_n)
        (wvalid && !wready) |=> $stable(wdata);
    endproperty
    AST_W02_WDATA_STABLE: assert property(p_wdata_stable)
        else $error("[%0t][ASSERT FAIL] W02: WDATA changed while WVALID high", $time);

    property p_wstrb_stable;
        @(posedge clk) disable iff (!rst_n)
        (wvalid && !wready) |=> $stable(wstrb);
    endproperty
    AST_W03_WSTRB_STABLE: assert property(p_wstrb_stable)
        else $error("[%0t][ASSERT FAIL] W03: WSTRB changed while WVALID high", $time);

    property p_wready_within_limit;
        @(posedge clk) disable iff (!rst_n)
        wvalid |-> ##[1:MAX_WAIT] wready;
    endproperty
    AST_W04_WREADY_TIMEOUT: assert property(p_wready_within_limit)
        else $error("[%0t][ASSERT FAIL] W04: WREADY timeout > %0d cycles", $time, MAX_WAIT);

    property p_wdata_no_x;
        @(posedge clk) disable iff (!rst_n)
        wvalid |-> !$isunknown(wdata);
    endproperty
    AST_W05_WDATA_NO_X: assert property(p_wdata_no_x)
        else $error("[%0t][ASSERT FAIL] W05: X/Z on WDATA during transfer", $time);

    property p_wstrb_nonzero;
        @(posedge clk) disable iff (!rst_n)
        wvalid |-> (wstrb != 4'b0000);
    endproperty
    AST_W06_WSTRB_NONZERO: assert property(p_wstrb_nonzero)
        else $error("[%0t][ASSERT FAIL] W06: WSTRB=0000 with WVALID asserted", $time);

    // =========================================================================
    // WRITE RESPONSE CHANNEL
    // =========================================================================
    property p_bvalid_after_write;
        @(posedge clk) disable iff (!rst_n)
        (awvalid && awready) |-> ##[1:MAX_WAIT] bvalid;
    endproperty
    AST_B01_BVALID_AFTER_WRITE: assert property(p_bvalid_after_write)
        else $error("[%0t][ASSERT FAIL] B01: BVALID not seen after write handshake", $time);

    property p_bvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (bvalid && !bready) |=> bvalid;
    endproperty
    AST_B02_BVALID_STABLE: assert property(p_bvalid_stable)
        else $error("[%0t][ASSERT FAIL] B02: BVALID dropped before BREADY", $time);

    property p_bresp_stable;
        @(posedge clk) disable iff (!rst_n)
        (bvalid && !bready) |=> $stable(bresp);
    endproperty
    AST_B03_BRESP_STABLE: assert property(p_bresp_stable)
        else $error("[%0t][ASSERT FAIL] B03: BRESP changed while BVALID high", $time);

    property p_bready_within_limit;
        @(posedge clk) disable iff (!rst_n)
        bvalid |-> ##[1:MAX_WAIT] bready;
    endproperty
    AST_B04_BREADY_TIMEOUT: assert property(p_bready_within_limit)
        else $error("[%0t][ASSERT FAIL] B04: BREADY timeout > %0d cycles", $time, MAX_WAIT);

    // =========================================================================
    // READ ADDRESS CHANNEL
    // =========================================================================
    property p_arvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (arvalid && !arready) |=> arvalid;
    endproperty
    AST_AR01_ARVALID_STABLE: assert property(p_arvalid_stable)
        else $error("[%0t][ASSERT FAIL] AR01: ARVALID dropped before ARREADY", $time);

    property p_araddr_stable;
        @(posedge clk) disable iff (!rst_n)
        (arvalid && !arready) |=> $stable(araddr);
    endproperty
    AST_AR02_ARADDR_STABLE: assert property(p_araddr_stable)
        else $error("[%0t][ASSERT FAIL] AR02: ARADDR changed while ARVALID high", $time);

    property p_arready_within_limit;
        @(posedge clk) disable iff (!rst_n)
        arvalid |-> ##[1:MAX_WAIT] arready;
    endproperty
    AST_AR03_ARREADY_TIMEOUT: assert property(p_arready_within_limit)
        else $error("[%0t][ASSERT FAIL] AR03: ARREADY timeout > %0d cycles", $time, MAX_WAIT);

    property p_araddr_aligned;
        @(posedge clk) disable iff (!rst_n)
        arvalid |-> (araddr[1:0] == 2'b00);
    endproperty
    AST_AR04_ARADDR_ALIGNED: assert property(p_araddr_aligned)
        else $error("[%0t][ASSERT FAIL] AR04: ARADDR not word-aligned", $time);

    property p_araddr_no_x;
        @(posedge clk) disable iff (!rst_n)
        arvalid |-> !$isunknown(araddr);
    endproperty
    AST_AR05_ARADDR_NO_X: assert property(p_araddr_no_x)
        else $error("[%0t][ASSERT FAIL] AR05: X/Z on ARADDR during transfer", $time);

    // =========================================================================
    // READ DATA CHANNEL
    // =========================================================================
    property p_rvalid_after_read;
        @(posedge clk) disable iff (!rst_n)
        (arvalid && arready) |-> ##[1:MAX_WAIT] rvalid;
    endproperty
    AST_R01_RVALID_AFTER_READ: assert property(p_rvalid_after_read)
        else $error("[%0t][ASSERT FAIL] R01: RVALID not seen after AR handshake", $time);

    property p_rvalid_stable;
        @(posedge clk) disable iff (!rst_n)
        (rvalid && !rready) |=> rvalid;
    endproperty
    AST_R02_RVALID_STABLE: assert property(p_rvalid_stable)
        else $error("[%0t][ASSERT FAIL] R02: RVALID dropped before RREADY", $time);

    property p_rdata_stable;
        @(posedge clk) disable iff (!rst_n)
        (rvalid && !rready) |=> $stable(rdata);
    endproperty
    AST_R03_RDATA_STABLE: assert property(p_rdata_stable)
        else $error("[%0t][ASSERT FAIL] R03: RDATA changed while RVALID high", $time);

    property p_rready_within_limit;
        @(posedge clk) disable iff (!rst_n)
        rvalid |-> ##[1:MAX_WAIT] rready;
    endproperty
    AST_R04_RREADY_TIMEOUT: assert property(p_rready_within_limit)
        else $error("[%0t][ASSERT FAIL] R04: RREADY timeout > %0d cycles", $time, MAX_WAIT);

    property p_rdata_no_x;
        @(posedge clk) disable iff (!rst_n)
        rvalid |-> !$isunknown(rdata);
    endproperty
    AST_R05_RDATA_NO_X: assert property(p_rdata_no_x)
        else $error("[%0t][ASSERT FAIL] R05: X/Z on RDATA during transfer", $time);

    // =========================================================================
    // RESET ASSERTIONS
    // =========================================================================
    AST_RST01: assert property(@(posedge clk) !rst_n |=> !awvalid)
        else $error("[%0t][ASSERT FAIL] RST01: AWVALID not deasserted after reset", $time);
    AST_RST02: assert property(@(posedge clk) !rst_n |=> !wvalid)
        else $error("[%0t][ASSERT FAIL] RST02: WVALID not deasserted after reset", $time);
    AST_RST03: assert property(@(posedge clk) !rst_n |=> !arvalid)
        else $error("[%0t][ASSERT FAIL] RST03: ARVALID not deasserted after reset", $time);
    AST_RST04: assert property(@(posedge clk) !rst_n |=> !bvalid)
        else $error("[%0t][ASSERT FAIL] RST04: BVALID not deasserted after reset", $time);
    AST_RST05: assert property(@(posedge clk) !rst_n |=> !rvalid)
        else $error("[%0t][ASSERT FAIL] RST05: RVALID not deasserted after reset", $time);

    // =========================================================================
    // COVER PROPERTIES
    // =========================================================================
    COV_AW_HANDSHAKE:  cover property(@(posedge clk) disable iff(!rst_n) awvalid && awready);
    COV_W_HANDSHAKE:   cover property(@(posedge clk) disable iff(!rst_n) wvalid  && wready);
    COV_B_HANDSHAKE:   cover property(@(posedge clk) disable iff(!rst_n) bvalid  && bready);
    COV_AR_HANDSHAKE:  cover property(@(posedge clk) disable iff(!rst_n) arvalid && arready);
    COV_R_HANDSHAKE:   cover property(@(posedge clk) disable iff(!rst_n) rvalid  && rready);
    COV_AW_WAIT:       cover property(@(posedge clk) disable iff(!rst_n) awvalid && !awready);
    COV_W_WAIT:        cover property(@(posedge clk) disable iff(!rst_n) wvalid  && !wready);
    COV_AR_WAIT:       cover property(@(posedge clk) disable iff(!rst_n) arvalid && !arready);
    COV_R_WAIT:        cover property(@(posedge clk) disable iff(!rst_n) rvalid  && !rready);

endmodule : axi4lite_assertions

`endif // AXI4LITE_ASSERTIONS_SV
