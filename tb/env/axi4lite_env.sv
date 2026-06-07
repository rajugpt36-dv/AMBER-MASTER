// =============================================================================
// File        : axi4lite_env.sv
// Description : AXI4-Lite UVM Environment
//               Instantiates agent, scoreboard, coverage; connects TLM ports.
// =============================================================================
`ifndef AXI4LITE_ENV_SV
`define AXI4LITE_ENV_SV

class axi4lite_env extends uvm_env;
    `uvm_component_utils(axi4lite_env)

    // -------------------------------------------------------------------------
    // Sub-components
    // -------------------------------------------------------------------------
    axi4lite_agent       agent;
    axi4lite_scoreboard  scoreboard;
    axi4lite_coverage    coverage;
    axi4lite_config      cfg;

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get config from config_db (set by test)
        if (!uvm_config_db #(axi4lite_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NO_CFG", "axi4lite_config not found in config_db")

        // Propagate config to agent
        uvm_config_db #(axi4lite_config)::set(this, "agent", "cfg", cfg);

        // Build components
        agent      = axi4lite_agent::type_id::create("agent",      this);
        scoreboard = axi4lite_scoreboard::type_id::create("scoreboard", this);

        if (cfg.has_coverage)
            coverage = axi4lite_coverage::type_id::create("coverage", this);
    endfunction

    // =========================================================================
    // connect_phase
    // =========================================================================
    function void connect_phase(uvm_phase phase);
        // Connect agent monitor AP -> scoreboard analysis export
        agent.ap.connect(scoreboard.analysis_export);

        // Connect agent monitor AP -> coverage analysis export
        if (cfg.has_coverage)
            agent.ap.connect(coverage.analysis_export);
    endfunction

    // =========================================================================
    // start_of_simulation_phase
    // =========================================================================
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Environment topology:", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

endclass : axi4lite_env

`endif // AXI4LITE_ENV_SV
