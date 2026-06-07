// =============================================================================
// File        : axi4lite_base_test.sv
// Description : AXI4-Lite UVM Base Test
//               All tests extend this. Builds env, applies reset, configures VIF.
// =============================================================================
`ifndef AXI4LITE_BASE_TEST_SV
`define AXI4LITE_BASE_TEST_SV

class axi4lite_base_test extends uvm_test;
    `uvm_component_utils(axi4lite_base_test)

    // -------------------------------------------------------------------------
    // Environment & config
    // -------------------------------------------------------------------------
    axi4lite_env    env;
    axi4lite_config cfg;

    // -------------------------------------------------------------------------
    // Virtual interface (retrieved from config_db set by tb_top)
    // -------------------------------------------------------------------------
    virtual axi4lite_if vif;

    // -------------------------------------------------------------------------
    // Test parameters (overridable from plusargs)
    // -------------------------------------------------------------------------
    int unsigned num_transactions = 20;
    int unsigned test_seed        = 0;

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve VIF from tb_top via config_db
        if (!uvm_config_db #(virtual axi4lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found in config_db")

        // Parse plusargs
        void'($value$plusargs("NTXN=%d",  num_transactions));
        void'($value$plusargs("SEED=%d",  test_seed));

        // Create and configure the agent config object
        cfg = axi4lite_config::type_id::create("cfg");
        cfg.vif          = vif;
        cfg.is_active    = UVM_ACTIVE;
        cfg.has_coverage = 1;

        // Push config into config_db for env and all sub-components
        uvm_config_db #(axi4lite_config)::set(this, "env",       "cfg", cfg);
        uvm_config_db #(axi4lite_config)::set(this, "env.agent", "cfg", cfg);

        // Build environment
        env = axi4lite_env::type_id::create("env", this);

        `uvm_info(get_type_name(),
            $sformatf("Build complete: num_transactions=%0d seed=%0d",
            num_transactions, test_seed), UVM_LOW)
    endfunction

    // =========================================================================
    // end_of_elaboration_phase - print topology
    // =========================================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    // =========================================================================
    // run_phase - apply reset; child tests override to start sequences
    // =========================================================================
    task run_phase(uvm_phase phase);
        phase.raise_objection(this, "test running");
        apply_reset();
        run_test_body(phase);
        phase.drop_objection(this, "test done");
    endtask

    // =========================================================================
    // apply_reset - waits for tb_top to complete reset sequence
    // rst_n starts 0 at time-0; tb_top deasserts after RESET_CYCLES clocks.
    // =========================================================================
    task automatic apply_reset();
        `uvm_info(get_type_name(), "Waiting for reset deassertion...", UVM_LOW)
        // If already high (should not happen at t=0), skip the wait
        if (vif.rst_n !== 1'b1)
            @(posedge vif.clk iff vif.rst_n === 1'b1);
        repeat(2) @(posedge vif.clk);
        `uvm_info(get_type_name(), "Reset deasserted. Starting test.", UVM_LOW)
    endtask

    // =========================================================================
    // run_test_body - overridden by each child test
    // =========================================================================
    virtual task run_test_body(uvm_phase phase);
        `uvm_fatal(get_type_name(), "run_test_body() not implemented")
    endtask

    // =========================================================================
    // report_phase
    // =========================================================================
    function void report_phase(uvm_phase phase);
        uvm_report_server rs = uvm_report_server::get_server();
        int unsigned errs  = rs.get_severity_count(UVM_ERROR);
        int unsigned fatals = rs.get_severity_count(UVM_FATAL);

        `uvm_info(get_type_name(), "\n", UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), "             UVM TEST REPORT SUMMARY              ", UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  UVM Errors  : %-6d                           ", errs), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("  UVM Fatals  : %-6d                           ", fatals), UVM_NONE)
        `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        if (errs == 0 && fatals == 0) begin
            `uvm_info(get_type_name(), "  _____        _____ _____  ", UVM_NONE)
            `uvm_info(get_type_name(), " |  __ \\ /\\   / ____/ ____| ", UVM_NONE)
            `uvm_info(get_type_name(), " | |__) /  \\ | (___| (___   ", UVM_NONE)
            `uvm_info(get_type_name(), " |  ___/ /\\ \\ \\___ \\\\___ \\  ", UVM_NONE)
            `uvm_info(get_type_name(), " | |  / ____ \\____) |___) | ", UVM_NONE)
            `uvm_info(get_type_name(), " |_| /_/    \\_\\_____/_____/ ", UVM_NONE)
            `uvm_info(get_type_name(), "                            ", UVM_NONE)
            `uvm_info(get_type_name(), "==================================================", UVM_NONE)
        end else begin
            `uvm_error(get_type_name(), "  ______      _____ _       ")
            `uvm_error(get_type_name(), " |  ____/\\   |_   _| |      ")
            `uvm_error(get_type_name(), " | |__ /  \\    | | | |      ")
            `uvm_error(get_type_name(), " |  __/ /\\ \\   | | | |      ")
            `uvm_error(get_type_name(), " | | / ____ \\ _| |_| |____  ")
            `uvm_error(get_type_name(), " |_|/_/    \\_\\_____|______| ")
            `uvm_error(get_type_name(), "                            ")
            `uvm_error(get_type_name(), "==================================================")
        end
    endfunction

endclass : axi4lite_base_test

`endif // AXI4LITE_BASE_TEST_SV
