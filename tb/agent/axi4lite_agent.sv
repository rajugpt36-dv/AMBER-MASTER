// =============================================================================
// File        : axi4lite_agent.sv
// Description : AXI4-Lite UVM Agent (active/passive configurable)
// =============================================================================
`ifndef AXI4LITE_AGENT_SV
`define AXI4LITE_AGENT_SV

class axi4lite_agent extends uvm_agent;
    `uvm_component_utils(axi4lite_agent)

    // -------------------------------------------------------------------------
    // Sub-components
    // -------------------------------------------------------------------------
    axi4lite_sequencer  seqr;
    axi4lite_driver     drv;
    axi4lite_monitor    mon;
    axi4lite_config     cfg;

    // -------------------------------------------------------------------------
    // TLM Analysis Port (relay from monitor)
    // -------------------------------------------------------------------------
    uvm_analysis_port #(axi4lite_seq_item) ap;

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_agent", uvm_component parent = null);
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

        // Always build monitor (active and passive)
        mon = axi4lite_monitor::type_id::create("mon", this);
        uvm_config_db #(axi4lite_config)::set(this, "mon", "cfg", cfg);

        if (cfg.is_active == UVM_ACTIVE) begin
            seqr = axi4lite_sequencer::type_id::create("seqr", this);
            drv  = axi4lite_driver::type_id::create("drv",  this);
            uvm_config_db #(axi4lite_config)::set(this, "drv",  "cfg", cfg);
        end
    endfunction

    // =========================================================================
    // connect_phase
    // =========================================================================
    function void connect_phase(uvm_phase phase);
        // Connect monitor AP to agent AP (relay)
        mon.ap.connect(ap);

        // Connect driver to sequencer (active mode only)
        if (cfg.is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

    // =========================================================================
    // start_of_simulation_phase
    // =========================================================================
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("Agent mode: %s", cfg.is_active.name()), UVM_LOW)
    endfunction

endclass : axi4lite_agent

`endif // AXI4LITE_AGENT_SV
