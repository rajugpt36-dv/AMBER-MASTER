// =============================================================================
// File        : axi4lite_coverage.sv
// Description : AXI4-Lite UVM Functional Coverage Collector
//               Subscribes to monitor analysis port and samples covergroups.
// =============================================================================
`ifndef AXI4LITE_COVERAGE_SV
`define AXI4LITE_COVERAGE_SV

class axi4lite_coverage extends uvm_subscriber #(axi4lite_seq_item);
    `uvm_component_utils(axi4lite_coverage)

    // -------------------------------------------------------------------------
    // Current item being sampled
    // -------------------------------------------------------------------------
    axi4lite_seq_item curr_item;

    // =========================================================================
    // Covergroup: Operation Type
    // =========================================================================
    covergroup cg_operation;
        cp_op: coverpoint curr_item.op {
            bins write_op = {AXI_WRITE};
            bins read_op  = {AXI_READ};
        }
    endgroup

    // =========================================================================
    // Covergroup: Address Range (Low / Mid / High)
    // =========================================================================
    covergroup cg_address_range;
        cp_addr: coverpoint curr_item.addr[11:10] {
            bins low  = {2'b00};        // 0x000 - 0x3FF
            bins mid  = {2'b01};        // 0x400 - 0x7FF
            bins high = {2'b10, 2'b11}; // 0x800 - 0xFFF
        }
    endgroup

    // =========================================================================
    // Covergroup: WSTRB - all 15 non-zero combinations
    // =========================================================================
    covergroup cg_wstrb;
        cp_wstrb: coverpoint curr_item.wstrb {
            bins b0_only  = {4'b0001};
            bins b1_only  = {4'b0010};
            bins b2_only  = {4'b0100};
            bins b3_only  = {4'b1000};
            bins b01      = {4'b0011};
            bins b02      = {4'b0101};
            bins b03      = {4'b1001};
            bins b12      = {4'b0110};
            bins b13      = {4'b1010};
            bins b23      = {4'b1100};
            bins b012     = {4'b0111};
            bins b013     = {4'b1011};
            bins b023     = {4'b1101};
            bins b123     = {4'b1110};
            bins b_all    = {4'b1111};
        }
    endgroup

    // =========================================================================
    // Covergroup: Data Patterns
    // =========================================================================
    covergroup cg_data_pattern;
        cp_data: coverpoint curr_item.data {
            bins all_zeros = {32'h0000_0000};
            bins all_ones  = {32'hFFFF_FFFF};
            bins walk_one  = {32'h0000_0001, 32'h0000_0002, 32'h0000_0004,
                              32'h0000_0008, 32'h0000_0010, 32'h0000_0020,
                              32'h0000_0040, 32'h0000_0080};
            bins random_val = default;
        }
    endgroup

    // =========================================================================
    // Covergroup: Response Codes
    // =========================================================================
    covergroup cg_response;
        cp_bresp: coverpoint curr_item.bresp {
            bins okay   = {AXI_OKAY};
            bins slverr = {AXI_SLVERR};
            ignore_bins exokay = {AXI_EXOKAY}; // Unsupported in AXI4-Lite
            ignore_bins decerr = {AXI_DECERR}; // Interconnect error, no interconnect present
        }
        cp_rresp: coverpoint curr_item.rresp {
            bins okay   = {AXI_OKAY};
            bins slverr = {AXI_SLVERR};
            ignore_bins exokay = {AXI_EXOKAY}; // Unsupported in AXI4-Lite
            ignore_bins decerr = {AXI_DECERR}; // Interconnect error, no interconnect present
        }
    endgroup

    // =========================================================================
    // Covergroup: Cross - Address Range x Operation
    // =========================================================================
    covergroup cg_cross_addr_op;
        cp_addr: coverpoint curr_item.addr[11:10] {
            bins low  = {2'b00};
            bins mid  = {2'b01};
            bins high = {2'b10, 2'b11};
        }
        cp_op: coverpoint curr_item.op {
            bins write_op = {AXI_WRITE};
            bins read_op  = {AXI_READ};
        }
        cx_addr_x_op: cross cp_addr, cp_op;
    endgroup

    // =========================================================================
    // Covergroup: Cross - Address Range x WSTRB Group
    // =========================================================================
    covergroup cg_cross_addr_wstrb;
        cp_addr: coverpoint curr_item.addr[11:10] {
            bins low  = {2'b00};
            bins mid  = {2'b01};
            bins high = {2'b10, 2'b11};
        }
        cp_wstrb_grp: coverpoint curr_item.wstrb {
            bins partial = {[4'b0001 : 4'b1110]};
            bins full    = {4'b1111};
        }
        cx_addr_x_wstrb: cross cp_addr, cp_wstrb_grp;
    endgroup

    // =========================================================================
    // Covergroup: AXI Transfer Size (byte count per wstrb)
    // =========================================================================
    covergroup cg_transfer_size;
        cp_size: coverpoint $countones(curr_item.wstrb) {
            bins one_byte   = {1};
            bins two_bytes  = {2};
            bins three_bytes = {3};
            bins four_bytes = {4};
        }
    endgroup

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_operation         = new();
        cg_address_range     = new();
        cg_wstrb             = new();
        cg_data_pattern      = new();
        cg_response          = new();
        cg_cross_addr_op     = new();
        cg_cross_addr_wstrb  = new();
        cg_transfer_size     = new();
    endfunction

    // =========================================================================
    // build_phase
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    // =========================================================================
    // write() - Called by analysis port for each observed transaction
    // =========================================================================
    function void write(axi4lite_seq_item t);
        curr_item = t;
        // Sample common covergroups
        cg_operation.sample();
        cg_address_range.sample();
        cg_data_pattern.sample();
        cg_response.sample();
        cg_cross_addr_op.sample();
        cg_cross_addr_wstrb.sample();
        // WSTRB only meaningful for writes
        if (t.op == AXI_WRITE) begin
            cg_wstrb.sample();
            cg_transfer_size.sample();
        end
    endfunction

    // =========================================================================
    // report_phase
    // =========================================================================
    function void report_phase(uvm_phase phase);
        real op_pct   = cg_operation.get_coverage();
        real addr_pct = cg_address_range.get_coverage();
        real wstr_pct = cg_wstrb.get_coverage();
        real data_pct = cg_data_pattern.get_coverage();
        real resp_pct = cg_response.get_coverage();
        real xao_pct  = cg_cross_addr_op.get_coverage();
        real xaw_pct  = cg_cross_addr_wstrb.get_coverage();
        real size_pct = cg_transfer_size.get_coverage();
        real overall  = (op_pct+addr_pct+wstr_pct+data_pct+resp_pct+xao_pct+xaw_pct+size_pct)/8.0;

        `uvm_info(get_type_name(), "\n", UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), "         FUNCTIONAL COVERAGE REPORT               ", UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Read/Write Ops      : %6.2f%%                  ", op_pct),   UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Address Range       : %6.2f%%                  ", addr_pct), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  WSTRB Values        : %6.2f%%                  ", wstr_pct), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Data Patterns       : %6.2f%%                  ", data_pct), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Response Codes      : %6.2f%%                  ", resp_pct), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Cross: Addr x Op    : %6.2f%%                  ", xao_pct),  UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Cross: Addr x WSTRB : %6.2f%%                  ", xaw_pct),  UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Transfer Size       : %6.2f%%                  ", size_pct), UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  OVERALL             : %6.2f%%                  ", overall),  UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
    endfunction

endclass : axi4lite_coverage

`endif // AXI4LITE_COVERAGE_SV
