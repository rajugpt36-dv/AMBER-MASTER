// =============================================================================
// File        : axi4lite_monitor.sv
// Description : AXI4-Lite UVM Monitor
//               Observes interface, emits complete transactions via TLM AP.
// =============================================================================
`ifndef AXI4LITE_MONITOR_SV
`define AXI4LITE_MONITOR_SV

class axi4lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi4lite_monitor)

    // -------------------------------------------------------------------------
    // TLM Analysis Port (broadcasts to scoreboard + coverage)
    // -------------------------------------------------------------------------
    uvm_analysis_port #(axi4lite_seq_item) ap;

    // -------------------------------------------------------------------------
    // Virtual interface & config
    // -------------------------------------------------------------------------
    virtual axi4lite_if.monitor_mp vif;
    axi4lite_config                cfg;

    // -------------------------------------------------------------------------
    // Statistics
    // -------------------------------------------------------------------------
    int unsigned write_observed = 0;
    int unsigned read_observed  = 0;

    // -------------------------------------------------------------------------
    // Queues for pipelined operations
    // -------------------------------------------------------------------------
    axi4lite_seq_item aw_q[$];
    axi4lite_seq_item w_q[$];
    axi4lite_seq_item ar_q[$];

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(axi4lite_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NO_CFG", "axi4lite_config not found in config_db")
        vif = cfg.vif.monitor_mp;
    endfunction

    // =========================================================================
    // run_phase - fork independent channel monitors
    // =========================================================================
    task run_phase(uvm_phase phase);
        if (vif.rst_n !== 1'b1)
            @(posedge vif.clk iff vif.rst_n === 1'b1);
        @(vif.monitor_cb);
        fork
            monitor_aw_channel();
            monitor_w_channel();
            monitor_b_channel();
            monitor_ar_channel();
            monitor_r_channel();
        join_none
    endtask

    // =========================================================================
    // Write Channels
    // =========================================================================
    task automatic monitor_aw_channel();
        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.awvalid && vif.monitor_cb.awready) begin
                axi4lite_seq_item item = axi4lite_seq_item::type_id::create("mon_aw");
                item.op   = AXI_WRITE;
                item.addr = vif.monitor_cb.awaddr;
                aw_q.push_back(item);
            end
        end
    endtask

    task automatic monitor_w_channel();
        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.wvalid && vif.monitor_cb.wready) begin
                axi4lite_seq_item item = axi4lite_seq_item::type_id::create("mon_w");
                item.data  = vif.monitor_cb.wdata;
                item.wstrb = vif.monitor_cb.wstrb;
                w_q.push_back(item);
            end
        end
    endtask

    task automatic monitor_b_channel();
        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.bvalid && vif.monitor_cb.bready) begin
                axi4lite_seq_item aw_item, w_item;
                axi4lite_seq_item final_item = axi4lite_seq_item::type_id::create("mon_wr");
                
                // Wait until we have both an AW and W phase captured
                wait (aw_q.size() > 0 && w_q.size() > 0);
                
                aw_item = aw_q.pop_front();
                w_item  = w_q.pop_front();

                final_item.op    = AXI_WRITE;
                final_item.addr  = aw_item.addr;
                final_item.data  = w_item.data;
                final_item.wstrb = w_item.wstrb;
                final_item.bresp = axi_resp_e'(vif.monitor_cb.bresp);

                `uvm_info(get_type_name(),
                    $sformatf("[MON_WR] %s", final_item.convert2string()), UVM_HIGH)

                ap.write(final_item);
                write_observed++;
            end
        end
    endtask

    // =========================================================================
    // Read Channels
    // =========================================================================
    task automatic monitor_ar_channel();
        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.arvalid && vif.monitor_cb.arready) begin
                axi4lite_seq_item item = axi4lite_seq_item::type_id::create("mon_ar");
                item.op   = AXI_READ;
                item.addr = vif.monitor_cb.araddr;
                ar_q.push_back(item);
            end
        end
    endtask

    task automatic monitor_r_channel();
        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.rvalid && vif.monitor_cb.rready) begin
                axi4lite_seq_item ar_item;
                axi4lite_seq_item final_item = axi4lite_seq_item::type_id::create("mon_rd");

                wait (ar_q.size() > 0);
                ar_item = ar_q.pop_front();

                final_item.op    = AXI_READ;
                final_item.addr  = ar_item.addr;
                final_item.rdata = vif.monitor_cb.rdata;
                final_item.rresp = axi_resp_e'(vif.monitor_cb.rresp);

                `uvm_info(get_type_name(),
                    $sformatf("[MON_RD] %s", final_item.convert2string()), UVM_HIGH)

                ap.write(final_item);
                read_observed++;
            end
        end
    endtask

    // =========================================================================
    // report_phase
    // =========================================================================
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("Monitor: writes_observed=%0d reads_observed=%0d",
            write_observed, read_observed), UVM_LOW)
        if (aw_q.size() > 0) `uvm_warning(get_type_name(), $sformatf("AW queue not empty (%0d items)", aw_q.size()))
        if (w_q.size() > 0)  `uvm_warning(get_type_name(), $sformatf("W queue not empty (%0d items)", w_q.size()))
        if (ar_q.size() > 0) `uvm_warning(get_type_name(), $sformatf("AR queue not empty (%0d items)", ar_q.size()))
    endfunction

endclass : axi4lite_monitor

`endif // AXI4LITE_MONITOR_SV
