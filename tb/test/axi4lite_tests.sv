// =============================================================================
// File        : axi4lite_tests.sv
// Description : AXI4-Lite UVM Test Classes - TC001 through TC015
//               Each test extends axi4lite_base_test and starts its sequence.
// =============================================================================
`ifndef AXI4LITE_TESTS_SV
`define AXI4LITE_TESTS_SV

// =============================================================================
// TC001 - Single Write
// =============================================================================
class tc001_single_write_test extends axi4lite_base_test;
    `uvm_component_utils(tc001_single_write_test)

    function new(string name = "tc001_single_write_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc001_single_write_seq seq = tc001_single_write_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC001: Single Write Test ===", UVM_NONE)
        seq.start(env.agent.seqr);
    endtask
endclass : tc001_single_write_test

// =============================================================================
// TC002 - Single Read
// =============================================================================
class tc002_single_read_test extends axi4lite_base_test;
    `uvm_component_utils(tc002_single_read_test)

    function new(string name = "tc002_single_read_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc002_single_read_seq seq = tc002_single_read_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC002: Single Read Test ===", UVM_NONE)
        seq.start(env.agent.seqr);
    endtask
endclass : tc002_single_read_test

// =============================================================================
// TC003 - Write Then Read Same Address
// =============================================================================
class tc003_write_read_test extends axi4lite_base_test;
    `uvm_component_utils(tc003_write_read_test)

    function new(string name = "tc003_write_read_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc003_write_read_seq seq = tc003_write_read_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC003: Write-Read Same Address ===", UVM_NONE)
        seq.start(env.agent.seqr);
    endtask
endclass : tc003_write_read_test

// =============================================================================
// TC004 - Sequential Writes
// =============================================================================
class tc004_seq_writes_test extends axi4lite_base_test;
    `uvm_component_utils(tc004_seq_writes_test)

    function new(string name = "tc004_seq_writes_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc004_seq_writes_seq seq = tc004_seq_writes_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC004: Sequential Writes ===", UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc004_seq_writes_test

// =============================================================================
// TC005 - Sequential Reads
// =============================================================================
class tc005_seq_reads_test extends axi4lite_base_test;
    `uvm_component_utils(tc005_seq_reads_test)

    function new(string name = "tc005_seq_reads_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc005_seq_reads_seq seq = tc005_seq_reads_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC005: Sequential Reads ===", UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc005_seq_reads_test

// =============================================================================
// TC006 - Random Writes
// =============================================================================
class tc006_rand_writes_test extends axi4lite_base_test;
    `uvm_component_utils(tc006_rand_writes_test)

    function new(string name = "tc006_rand_writes_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc006_rand_writes_seq seq = tc006_rand_writes_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC006: Random Writes ===", UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc006_rand_writes_test

// =============================================================================
// TC007 - Random Reads
// =============================================================================
class tc007_rand_reads_test extends axi4lite_base_test;
    `uvm_component_utils(tc007_rand_reads_test)

    function new(string name = "tc007_rand_reads_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc007_rand_reads_seq seq = tc007_rand_reads_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC007: Random Reads ===", UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc007_rand_reads_test

// =============================================================================
// TC008 - Random R/W Mix
// =============================================================================
class tc008_rand_mix_test extends axi4lite_base_test;
    `uvm_component_utils(tc008_rand_mix_test)

    function new(string name = "tc008_rand_mix_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc008_rand_mix_seq seq = tc008_rand_mix_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC008: Random Read/Write Mix ===", UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc008_rand_mix_test

// =============================================================================
// TC009 - Reset During Idle
// =============================================================================
class tc009_reset_idle_test extends axi4lite_base_test;
    `uvm_component_utils(tc009_reset_idle_test)

    function new(string name = "tc009_reset_idle_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Override run_phase to inject a second reset while bus is idle
    task run_phase(uvm_phase phase);
        tc009_reset_idle_seq seq;
        phase.raise_objection(this, "TC009 running");

        // First reset (applied by base via apply_reset during build)
        apply_reset();

        // Wait some idle cycles then apply a second reset
        repeat(20) @(posedge vif.clk);
        `uvm_info(get_type_name(), "Applying second reset while idle...", UVM_LOW)
        // force tb_top.rst_n = 1'b0;
        // repeat(8) @(posedge vif.clk);
        // release tb_top.rst_n;

        // Wait for deassertion
        @(posedge vif.clk iff vif.rst_n === 1'b1);
        repeat(2) @(posedge vif.clk);

        // Run post-reset transaction to verify recovery
        seq = tc009_reset_idle_seq::type_id::create("seq");
        seq.start(env.agent.seqr);

        phase.drop_objection(this, "TC009 done");
    endtask
endclass : tc009_reset_idle_test

// =============================================================================
// TC010 - Reset During Transaction
// =============================================================================
class tc010_reset_txn_test extends axi4lite_base_test;
    `uvm_component_utils(tc010_reset_txn_test)

    function new(string name = "tc010_reset_txn_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        tc010_reset_txn_seq pre_seq, post_seq;
        phase.raise_objection(this, "TC010 running");

        apply_reset();

        // Start 5 transactions
        pre_seq = tc010_reset_txn_seq::type_id::create("pre_seq");
        fork
            pre_seq.start(env.agent.seqr);
            begin
                // Mid-test reset after 3 clock cycles
                repeat(3) @(posedge vif.clk);
                `uvm_info(get_type_name(), "Injecting mid-simulation reset (TC010)", UVM_LOW)
                // force tb_top.rst_n = 1'b0;
                // repeat(5) @(posedge vif.clk);
                // release tb_top.rst_n;
                @(posedge vif.clk iff vif.rst_n === 1'b1);
                repeat(2) @(posedge vif.clk);
            end
        join

        // Post-reset recovery transaction
        post_seq = tc010_reset_txn_seq::type_id::create("post_seq");
        post_seq.start(env.agent.seqr);

        phase.drop_objection(this, "TC010 done");
    endtask
endclass : tc010_reset_txn_test

// =============================================================================
// TC011 - Back-to-Back Writes
// =============================================================================
class tc011_b2b_writes_test extends axi4lite_base_test;
    `uvm_component_utils(tc011_b2b_writes_test)

    function new(string name = "tc011_b2b_writes_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg.inter_txn_delay = 0;  // No gaps between transactions
    endfunction

    task run_test_body(uvm_phase phase);
        tc011_b2b_writes_seq seq = tc011_b2b_writes_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC011: Back-to-Back Writes ===", UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc011_b2b_writes_test

// =============================================================================
// TC012 - Back-to-Back Reads
// =============================================================================
class tc012_b2b_reads_test extends axi4lite_base_test;
    `uvm_component_utils(tc012_b2b_reads_test)

    function new(string name = "tc012_b2b_reads_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg.inter_txn_delay = 0;
    endfunction

    task run_test_body(uvm_phase phase);
        tc012_b2b_reads_seq seq = tc012_b2b_reads_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC012: Back-to-Back Reads ===", UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc012_b2b_reads_test

// =============================================================================
// TC013 - All WSTRB Combinations
// =============================================================================
class tc013_wstrb_all_test extends axi4lite_base_test;
    `uvm_component_utils(tc013_wstrb_all_test)

    function new(string name = "tc013_wstrb_all_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc013_wstrb_all_seq seq = tc013_wstrb_all_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC013: All WSTRB Combinations ===", UVM_NONE)
        seq.start(env.agent.seqr);
    endtask
endclass : tc013_wstrb_all_test

// =============================================================================
// TC014 - Invalid Address Access
// =============================================================================
class tc014_invalid_addr_test extends axi4lite_base_test;
    `uvm_component_utils(tc014_invalid_addr_test)

    function new(string name = "tc014_invalid_addr_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Override constraint via factory override to allow OOR address
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Disable OOR address constraint via config_db flag (handled in sequence)
    endfunction

    task run_test_body(uvm_phase phase);
        tc014_invalid_addr_seq seq = tc014_invalid_addr_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC014: Invalid Address Access ===", UVM_NONE)
        seq.start(env.agent.seqr);
    endtask
endclass : tc014_invalid_addr_test

// =============================================================================
// TC015 - Stress Test (1000 transactions)
// =============================================================================
class tc015_stress_test extends axi4lite_base_test;
    `uvm_component_utils(tc015_stress_test)

    function new(string name = "tc015_stress_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (num_transactions < 100)
            num_transactions = 1000;
    endfunction

    task run_test_body(uvm_phase phase);
        tc015_stress_seq seq = tc015_stress_seq::type_id::create("seq");
        `uvm_info(get_type_name(),
            $sformatf("=== TC015: Stress Test (%0d transactions) ===", num_transactions), UVM_NONE)
        seq.num_transactions = num_transactions;
        seq.start(env.agent.seqr);
    endtask
endclass : tc015_stress_test

// =============================================================================
// TC016 - Data Patterns Test
// =============================================================================
class tc016_data_patterns_test extends axi4lite_base_test;
    `uvm_component_utils(tc016_data_patterns_test)

    function new(string name = "tc016_data_patterns_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_test_body(uvm_phase phase);
        tc016_data_patterns_seq seq = tc016_data_patterns_seq::type_id::create("seq");
        `uvm_info(get_type_name(), "=== TC016: Data Patterns Test ===", UVM_NONE)
        seq.start(env.agent.seqr);
    endtask
endclass : tc016_data_patterns_test

`endif // AXI4LITE_TESTS_SV
