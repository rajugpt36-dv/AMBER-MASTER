// =============================================================================
// File        : axi4lite_scoreboard.sv
// Description : AXI4-Lite UVM Scoreboard
//               Implements reference memory model, compares observed transactions.
// =============================================================================
`ifndef AXI4LITE_SCOREBOARD_SV
`define AXI4LITE_SCOREBOARD_SV

class axi4lite_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi4lite_scoreboard)

    // -------------------------------------------------------------------------
    // TLM Analysis Export (receives from monitor via agent AP)
    // -------------------------------------------------------------------------
    uvm_analysis_imp #(axi4lite_seq_item, axi4lite_scoreboard) analysis_export;

    // -------------------------------------------------------------------------
    // Reference Memory Model (associative array: byte_addr -> word_data)
    // -------------------------------------------------------------------------
    bit [31:0] expected_mem [bit [31:0]];

    // -------------------------------------------------------------------------
    // Statistics
    // -------------------------------------------------------------------------
    int unsigned pass_count  = 0;
    int unsigned fail_count  = 0;
    int unsigned write_count = 0;
    int unsigned read_count  = 0;

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction

    // =========================================================================
    // write() - TLM analysis imp callback
    // =========================================================================
    function void write(axi4lite_seq_item item);
        if (item.op == AXI_WRITE)
            check_write(item);
        else
            check_read(item);
    endfunction

    // =========================================================================
    // check_write() - Update reference model, verify BRESP
    // =========================================================================
    function void check_write(axi4lite_seq_item item);
        bit [31:0] base_addr = {item.addr[31:2], 2'b00};
        bit [31:0] prev_data = expected_mem.exists(base_addr) ?
                               expected_mem[base_addr] : 32'h0;
        bit [31:0] new_data  = prev_data;
        axi_resp_e expected_bresp = (base_addr > 32'h0000_0FFC) ? AXI_SLVERR : AXI_OKAY;

        // Apply write strobes byte-by-byte
        if (item.wstrb[0]) new_data[7:0]   = item.data[7:0];
        if (item.wstrb[1]) new_data[15:8]  = item.data[15:8];
        if (item.wstrb[2]) new_data[23:16] = item.data[23:16];
        if (item.wstrb[3]) new_data[31:24] = item.data[31:24];

        // Only update expected memory if it's a valid address, else memory state doesn't change
        if (expected_bresp == AXI_OKAY) begin
            expected_mem[base_addr] = new_data;
        end

        // Verify BRESP
        if (item.bresp !== expected_bresp) begin
            `uvm_error("SCB_WRITE",
                $sformatf("BRESP MISMATCH: ADDR=0x%08h EXP=%s GOT=%s",
                base_addr, expected_bresp.name(), item.bresp.name()))
            fail_count++;
        end else begin
            `uvm_info("SCB_WRITE",
                $sformatf("[PASS] WRITE ADDR=0x%08h DATA=0x%08h WSTRB=4'b%04b -> MEM=0x%08h",
                base_addr, item.data, item.wstrb, new_data), UVM_HIGH)
            pass_count++;
        end

        write_count++;
    endfunction : check_write

    // =========================================================================
    // check_read() - Compare observed vs reference memory
    // =========================================================================
    function void check_read(axi4lite_seq_item item);
        bit [31:0] base_addr = {item.addr[31:2], 2'b00};
        bit [31:0] exp_data;
        axi_resp_e expected_rresp = (base_addr > 32'h0000_0FFC) ? AXI_SLVERR : AXI_OKAY;

        // Skip OOR address data comparison
        if (base_addr > 32'h0000_0FFC) begin
            `uvm_info("SCB_READ",
                $sformatf("[INFO] OOR ADDR=0x%08h - skipping data check", base_addr), UVM_MEDIUM)
            pass_count++;
            read_count++;
            return;
        end

        exp_data = expected_mem.exists(base_addr) ? expected_mem[base_addr] : 32'h0;

        if (item.rdata !== exp_data) begin
            `uvm_error("SCB_READ",
                $sformatf("DATA MISMATCH: ADDR=0x%08h EXP=0x%08h GOT=0x%08h",
                base_addr, exp_data, item.rdata))
            fail_count++;
        end else begin
            `uvm_info("SCB_READ",
                $sformatf("[PASS] READ  ADDR=0x%08h RDATA=0x%08h",
                base_addr, item.rdata), UVM_HIGH)
            pass_count++;
        end

        // Verify RRESP
        if (item.rresp !== expected_rresp) begin
            `uvm_error("SCB_READ",
                $sformatf("RRESP MISMATCH: ADDR=0x%08h EXP=%s GOT=%s",
                base_addr, expected_rresp.name(), item.rresp.name()))
            fail_count++;
        end

        read_count++;
    endfunction : check_read

    // =========================================================================
    // backdoor_write() - Pre-load reference model
    // =========================================================================
    function void backdoor_write(bit [31:0] addr, bit [31:0] data);
        expected_mem[{addr[31:2], 2'b00}] = data;
    endfunction

    // =========================================================================
    // report_phase
    // =========================================================================
    function void report_phase(uvm_phase phase);
        int unsigned total    = pass_count + fail_count;
        real         pass_pct = (total > 0) ? (real'(pass_count)/real'(total))*100.0 : 0.0;

        `uvm_info(get_type_name(), "\n", UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), "           SCOREBOARD SUMMARY                     ", UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Writes  Checked : %-6d                       ", write_count), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  Reads   Checked : %-6d                       ", read_count), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  PASS            : %-6d  (%5.1f%%)             ", pass_count, pass_pct), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  FAIL            : %-6d                       ", fail_count), UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)

        if (fail_count == 0) begin
            `uvm_info(get_type_name(), "  STATUS : ** SIMULATION PASSED **                ", UVM_NONE)
        end else begin
            `uvm_error(get_type_name(), "  STATUS : ** SIMULATION FAILED **                ")
        end
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
    endfunction

endclass : axi4lite_scoreboard

`endif // AXI4LITE_SCOREBOARD_SV
