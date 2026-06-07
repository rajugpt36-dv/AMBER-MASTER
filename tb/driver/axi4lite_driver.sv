// =============================================================================
// File        : axi4lite_driver.sv
// Description : AXI4-Lite UVM Driver
//               Pulls seq items from sequencer, drives AXI4-Lite protocol.
// =============================================================================
`ifndef AXI4LITE_DRIVER_SV
`define AXI4LITE_DRIVER_SV

class axi4lite_driver extends uvm_driver #(axi4lite_seq_item);
    `uvm_component_utils(axi4lite_driver)

    // -------------------------------------------------------------------------
    // Virtual interface & config
    // -------------------------------------------------------------------------
    virtual axi4lite_if.master_mp vif;
    axi4lite_config               cfg;

    // -------------------------------------------------------------------------
    // Statistics
    // -------------------------------------------------------------------------
    int unsigned write_count  = 0;
    int unsigned read_count   = 0;
    int unsigned timeout_count = 0;

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(axi4lite_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NO_CFG", "axi4lite_config not found in config_db")
        vif = cfg.vif.master_mp;
    endfunction

    // =========================================================================
    // run_phase
    // =========================================================================
    task run_phase(uvm_phase phase);
        axi4lite_seq_item req_item;

        // Drive safe reset state
        reset_signals();
        // Wait for reset deassertion (rst_n starts 0 at time-0 from tb_top)
        if (vif.rst_n !== 1'b1)
            @(posedge vif.clk iff vif.rst_n === 1'b1);
        @(vif.master_cb);

        forever begin
            seq_item_port.get_next_item(req_item);
            `uvm_info(get_type_name(),
                $sformatf("Driving: %s", req_item.convert2string()), UVM_HIGH)

            if (req_item.op == AXI_WRITE)
                drive_write(req_item);
            else
                drive_read(req_item);

            seq_item_port.item_done();

            // Inter-transaction gap
            if (cfg.inter_txn_delay > 0)
                repeat(cfg.inter_txn_delay) @(vif.master_cb);
        end
    endtask

    // =========================================================================
    // reset_signals - Drive all master outputs to inactive state
    // =========================================================================
    task automatic reset_signals();
        vif.master_cb.awaddr  <= '0;
        vif.master_cb.awvalid <= 1'b0;
        vif.master_cb.wdata   <= '0;
        vif.master_cb.wstrb   <= 4'b1111;
        vif.master_cb.wvalid  <= 1'b0;
        vif.master_cb.bready  <= 1'b0;
        vif.master_cb.araddr  <= '0;
        vif.master_cb.arvalid <= 1'b0;
        vif.master_cb.rready  <= 1'b0;
    endtask

    // =========================================================================
    // drive_write - AW + W + B phases
    // =========================================================================
    task automatic drive_write(axi4lite_seq_item item);
        bit aw_done = 0;
        bit w_done  = 0;
        int aw_timeout = 0;
        int w_timeout  = 0;
        int b_timeout  = 0;

        // Drive AW and W concurrently
        fork
            // ---- Write Address Phase ----
            begin
                repeat(cfg.aw_wait_states) @(vif.master_cb);
                vif.master_cb.awaddr  <= item.addr;
                vif.master_cb.awvalid <= 1'b1;
                do begin
                    @(vif.master_cb);
                    if (++aw_timeout >= cfg.max_wait_cycles) begin
                        `uvm_error(get_type_name(), $sformatf("AWREADY TIMEOUT at ADDR=0x%08h", item.addr))
                        timeout_count++;
                        break;
                    end
                end while (!vif.master_cb.awready);
                vif.master_cb.awvalid <= 1'b0;
                vif.master_cb.awaddr  <= '0;
                aw_done = 1;
            end
            
            // ---- Write Data Phase ----
            begin
                repeat(cfg.w_wait_states) @(vif.master_cb);
                vif.master_cb.wdata  <= item.data;
                vif.master_cb.wstrb  <= item.wstrb;
                vif.master_cb.wvalid <= 1'b1;
                do begin
                    @(vif.master_cb);
                    if (++w_timeout >= cfg.max_wait_cycles) begin
                        `uvm_error(get_type_name(), $sformatf("WREADY TIMEOUT at ADDR=0x%08h", item.addr))
                        timeout_count++;
                        break;
                    end
                end while (!vif.master_cb.wready);
                vif.master_cb.wvalid <= 1'b0;
                vif.master_cb.wdata  <= '0;
                vif.master_cb.wstrb  <= 4'b1111;
                w_done = 1;
            end
        join

        if (!aw_done || !w_done) begin
            goto_idle_write();
            return;
        end

        // ---- Write Response Phase ----
        // Randomize bready assertion to test slave's bvalid stability
        repeat($urandom_range(0, 2)) @(vif.master_cb);
        vif.master_cb.bready <= 1'b1;
        do begin
            @(vif.master_cb);
            if (++b_timeout >= cfg.max_wait_cycles) begin
                `uvm_error(get_type_name(), $sformatf("BVALID TIMEOUT at ADDR=0x%08h", item.addr))
                timeout_count++;
                vif.master_cb.bready <= 1'b0;
                return;
            end
        end while (!vif.master_cb.bvalid);

        item.bresp = axi_resp_e'(vif.master_cb.bresp);
        vif.master_cb.bready <= 1'b0;

        write_count++;
        `uvm_info(get_type_name(),
            $sformatf("[WRITE] ADDR=0x%08h DATA=0x%08h WSTRB=4'b%04b BRESP=%s",
            item.addr, item.data, item.wstrb, item.bresp.name()), UVM_MEDIUM)

    endtask : drive_write

    // =========================================================================
    // drive_read - AR + R phases
    // =========================================================================
    task automatic drive_read(axi4lite_seq_item item);
        int ar_timeout = 0;
        int r_timeout  = 0;

        repeat(cfg.ar_wait_states) @(vif.master_cb);

        // ---- Read Address Phase --------------------------------------------
        vif.master_cb.araddr  <= item.addr;
        vif.master_cb.arvalid <= 1'b1;

        do begin
            @(vif.master_cb);
            if (++ar_timeout >= cfg.max_wait_cycles) begin
                `uvm_error(get_type_name(),
                    $sformatf("ARREADY TIMEOUT at ADDR=0x%08h after %0d cycles",
                    item.addr, cfg.max_wait_cycles))
                timeout_count++;
                vif.master_cb.arvalid <= 1'b0;
                vif.master_cb.araddr  <= '0;
                return;
            end
        end while (!vif.master_cb.arready);
        
        vif.master_cb.arvalid <= 1'b0;
        vif.master_cb.araddr  <= '0;

        // ---- Read Data Phase -----------------------------------------------
        // Randomize rready assertion to test slave's rvalid stability
        repeat($urandom_range(0, 2)) @(vif.master_cb);
        vif.master_cb.rready <= 1'b1;
        do begin
            @(vif.master_cb);
            if (++r_timeout >= cfg.max_wait_cycles) begin
                `uvm_error(get_type_name(),
                    $sformatf("RVALID TIMEOUT at ADDR=0x%08h after %0d cycles",
                    item.addr, cfg.max_wait_cycles))
                timeout_count++;
                vif.master_cb.rready <= 1'b0;
                return;
            end
        end while (!vif.master_cb.rvalid);
        
        item.rdata = vif.master_cb.rdata;
        item.rresp = axi_resp_e'(vif.master_cb.rresp);
        vif.master_cb.rready <= 1'b0;

        read_count++;
        `uvm_info(get_type_name(),
            $sformatf("[READ ] ADDR=0x%08h RDATA=0x%08h RRESP=%s",
            item.addr, item.rdata, item.rresp.name()), UVM_MEDIUM)

    endtask : drive_read

    // =========================================================================
    // goto_idle_write - cleanup on write timeout
    // =========================================================================
    task automatic goto_idle_write();
        vif.master_cb.awvalid <= 1'b0;
        vif.master_cb.wvalid  <= 1'b0;
        vif.master_cb.bready  <= 1'b0;
        vif.master_cb.awaddr  <= '0;
        vif.master_cb.wdata   <= '0;
        @(vif.master_cb);
    endtask

    // =========================================================================
    // report_phase
    // =========================================================================
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("Driver: writes=%0d reads=%0d timeouts=%0d",
            write_count, read_count, timeout_count), UVM_LOW)
    endfunction

endclass : axi4lite_driver

`endif // AXI4LITE_DRIVER_SV
