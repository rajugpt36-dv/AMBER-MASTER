// =============================================================================
// File        : axi4lite_seq_item.sv
// Description : AXI4-Lite UVM Sequence Item
// =============================================================================
`ifndef AXI4LITE_SEQ_ITEM_SV
`define AXI4LITE_SEQ_ITEM_SV

class axi4lite_seq_item extends uvm_sequence_item;

    // -------------------------------------------------------------------------
    // Randomizable fields
    // -------------------------------------------------------------------------
    rand axi_op_e          op;
    rand bit [31:0]        addr;
    rand bit [31:0]        data;
    rand bit [3:0]         wstrb;

    // Non-rand: filled by driver/monitor
    bit [31:0]             rdata;
    axi_resp_e             bresp;
    axi_resp_e             rresp;

    `uvm_object_utils_begin(axi4lite_seq_item)
        `uvm_field_enum(axi_op_e,   op,    UVM_ALL_ON)
        `uvm_field_int (addr,               UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (data,               UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (wstrb,              UVM_ALL_ON | UVM_BIN)
        `uvm_field_int (rdata,              UVM_ALL_ON | UVM_HEX)
        `uvm_field_enum(axi_resp_e, bresp,  UVM_ALL_ON)
        `uvm_field_enum(axi_resp_e, rresp,  UVM_ALL_ON)
    `uvm_object_utils_end

    // =========================================================================
    // Constraints
    // =========================================================================
    constraint c_addr_aligned { addr[1:0] == 2'b00; }

    constraint c_addr_range {
        addr inside {[32'h0000_0000 : 32'h0000_0FFC]};
    }

    constraint c_wstrb_valid { wstrb != 4'b0000; }

    constraint c_op_dist {
        op dist { AXI_WRITE := 50, AXI_READ := 50 };
    }

    constraint c_data_dist {
        data dist {
            32'h0000_0000          := 5,
            32'hFFFF_FFFF          := 5,
            [32'h0001 : 32'hFFFE]  := 90
        };
    }

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_seq_item");
        super.new(name);
    endfunction

    // =========================================================================
    // do_copy
    // =========================================================================
    function void do_copy(uvm_object rhs);
        axi4lite_seq_item rhs_item;
        super.do_copy(rhs);
        if (!$cast(rhs_item, rhs))
            `uvm_fatal("DO_COPY", "Cast failed")
        this.op    = rhs_item.op;
        this.addr  = rhs_item.addr;
        this.data  = rhs_item.data;
        this.wstrb = rhs_item.wstrb;
        this.rdata = rhs_item.rdata;
        this.bresp = rhs_item.bresp;
        this.rresp = rhs_item.rresp;
    endfunction

    // =========================================================================
    // do_compare
    // =========================================================================
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        axi4lite_seq_item rhs_item;
        bit result = super.do_compare(rhs, comparer);
        if (!$cast(rhs_item, rhs))
            `uvm_fatal("DO_COMPARE", "Cast failed")
        result &= (this.op    === rhs_item.op);
        result &= (this.addr  === rhs_item.addr);
        if (this.op == AXI_WRITE)
            result &= (this.data  === rhs_item.data);
        else
            result &= (this.rdata === rhs_item.rdata);
        return result;
    endfunction

    // =========================================================================
    // convert2string
    // =========================================================================
    function string convert2string();
        return $sformatf("[%s] ADDR=0x%08h DATA=0x%08h RDATA=0x%08h WSTRB=4'b%04b BRESP=%s RRESP=%s",
            op.name(), addr, data, rdata, wstrb, bresp.name(), rresp.name());
    endfunction



endclass : axi4lite_seq_item

`endif // AXI4LITE_SEQ_ITEM_SV
