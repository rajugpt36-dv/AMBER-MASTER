// =============================================================================
// File        : axi4lite_pkg.sv
// Description : AXI4-Lite UVM Package - bundles all UVM components
// =============================================================================
`ifndef AXI4LITE_PKG_SV
`define AXI4LITE_PKG_SV

package axi4lite_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // =========================================================================
    // Parameters
    // =========================================================================
    parameter int AXI_ADDR_WIDTH = 32;
    parameter int AXI_DATA_WIDTH = 32;
    parameter int AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

    // AXI response codes
    typedef enum logic [1:0] {
        AXI_OKAY   = 2'b00,
        AXI_EXOKAY = 2'b01,
        AXI_SLVERR = 2'b10,
        AXI_DECERR = 2'b11
    } axi_resp_e;

    // Operation type
    typedef enum bit {
        AXI_WRITE = 1'b1,
        AXI_READ  = 1'b0
    } axi_op_e;

    // =========================================================================
    // Include all UVM components (order matters)
    // =========================================================================
    `include "axi4lite_seq_item.sv"
    `include "axi4lite_config.sv"
    `include "axi4lite_sequencer.sv"
    `include "axi4lite_driver.sv"
    `include "axi4lite_monitor.sv"
    `include "axi4lite_agent.sv"
    `include "axi4lite_scoreboard.sv"
    `include "axi4lite_coverage.sv"
    `include "axi4lite_env.sv"
    `include "axi4lite_base_seq.sv"
    `include "axi4lite_sequences.sv"
    `include "axi4lite_base_test.sv"
    `include "axi4lite_tests.sv"

endpackage : axi4lite_pkg

`endif // AXI4LITE_PKG_SV
