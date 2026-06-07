// =============================================================================
// File        : axi4lite_sequences.sv
// Description : AXI4-Lite UVM Sequences - TC001 through TC015
// =============================================================================
`ifndef AXI4LITE_SEQUENCES_SV
`define AXI4LITE_SEQUENCES_SV

// =============================================================================
// TC001 - Single Write
// =============================================================================
class tc001_single_write_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc001_single_write_seq)

    function new(string name = "tc001_single_write_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC001: Single Write", UVM_LOW)
        do_write(32'h0000_0100, 32'hCAFE_BABE, 4'b1111);
    endtask
endclass : tc001_single_write_seq

// =============================================================================
// TC002 - Single Read
// =============================================================================
class tc002_single_read_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc002_single_read_seq)

    function new(string name = "tc002_single_read_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC002: Single Read", UVM_LOW)
        do_read(32'h0000_0100);
    endtask
endclass : tc002_single_read_seq

// =============================================================================
// TC003 - Write Then Read Same Address
// =============================================================================
class tc003_write_read_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc003_write_read_seq)

    function new(string name = "tc003_write_read_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC003: Write then Read same address", UVM_LOW)
        do_write(32'h0000_0200, 32'hDEAD_BEEF, 4'b1111);
        do_read (32'h0000_0200);
    endtask
endclass : tc003_write_read_seq

// =============================================================================
// TC004 - Multiple Sequential Writes
// =============================================================================
class tc004_seq_writes_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc004_seq_writes_seq)

    function new(string name = "tc004_seq_writes_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC004: %0d Sequential Writes", num_transactions), UVM_LOW)
        for (int i = 0; i < num_transactions; i++)
            do_write(32'(i * 4), 32'hA000_0000 | 32'(i), 4'b1111);
    endtask
endclass : tc004_seq_writes_seq

// =============================================================================
// TC005 - Multiple Sequential Reads
// =============================================================================
class tc005_seq_reads_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc005_seq_reads_seq)

    function new(string name = "tc005_seq_reads_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC005: %0d Sequential Reads", num_transactions), UVM_LOW)
        for (int i = 0; i < num_transactions; i++)
            do_read(32'(i * 4));
    endtask
endclass : tc005_seq_reads_seq

// =============================================================================
// TC006 - Random Writes
// =============================================================================
class tc006_rand_writes_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc006_rand_writes_seq)

    function new(string name = "tc006_rand_writes_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC006: %0d Random Writes", num_transactions), UVM_LOW)
        repeat(num_transactions)
            do_rand_write();
    endtask
endclass : tc006_rand_writes_seq

// =============================================================================
// TC007 - Random Reads
// =============================================================================
class tc007_rand_reads_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc007_rand_reads_seq)

    function new(string name = "tc007_rand_reads_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC007: %0d Random Reads", num_transactions), UVM_LOW)
        repeat(num_transactions)
            do_rand_read();
    endtask
endclass : tc007_rand_reads_seq

// =============================================================================
// TC008 - Random Read/Write Mix
// =============================================================================
class tc008_rand_mix_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc008_rand_mix_seq)

    function new(string name = "tc008_rand_mix_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC008: %0d Random R/W Mix", num_transactions), UVM_LOW)
        repeat(num_transactions)
            do_rand_item();
    endtask
endclass : tc008_rand_mix_seq

// =============================================================================
// TC009 - Reset During Idle (handled mostly in test; seq does 1 txn post-reset)
// =============================================================================
class tc009_reset_idle_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc009_reset_idle_seq)

    function new(string name = "tc009_reset_idle_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC009: Post-reset single write", UVM_LOW)
        do_write(32'h0000_0004, 32'hABCD_1234, 4'b1111);
    endtask
endclass : tc009_reset_idle_seq

// =============================================================================
// TC010 - Reset During Transaction (seq generates pre-reset traffic)
// =============================================================================
class tc010_reset_txn_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc010_reset_txn_seq)

    function new(string name = "tc010_reset_txn_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC010: Traffic before/after mid-sim reset", UVM_LOW)
        repeat(5) do_rand_item();
    endtask
endclass : tc010_reset_txn_seq

// =============================================================================
// TC011 - Back-to-Back Writes (no idle gaps; inter_txn_delay=0 set by test)
// =============================================================================
class tc011_b2b_writes_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc011_b2b_writes_seq)

    function new(string name = "tc011_b2b_writes_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC011: %0d Back-to-Back Writes", num_transactions), UVM_LOW)
        for (int i = 0; i < num_transactions; i++)
            do_write(32'h0000_0400 + 32'(i*4), 32'hB2B0_0000 | 32'(i), 4'b1111);
    endtask
endclass : tc011_b2b_writes_seq

// =============================================================================
// TC012 - Back-to-Back Reads
// =============================================================================
class tc012_b2b_reads_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc012_b2b_reads_seq)

    function new(string name = "tc012_b2b_reads_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC012: %0d Back-to-Back Reads", num_transactions), UVM_LOW)
        for (int i = 0; i < num_transactions; i++)
            do_read(32'h0000_0400 + 32'(i*4));
    endtask
endclass : tc012_b2b_reads_seq

// =============================================================================
// TC013 - All WSTRB Combinations (15 non-zero values)
// =============================================================================
class tc013_wstrb_all_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc013_wstrb_all_seq)

    function new(string name = "tc013_wstrb_all_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC013: All 15 WSTRB combinations", UVM_LOW)
        for (int s = 1; s <= 15; s++) begin
            do_write(32'(s * 4), 32'hFF00_0000 | 32'(s), s[3:0]);
            // Read back to verify strobe accuracy
            do_read(32'(s * 4));
        end
    endtask
endclass : tc013_wstrb_all_seq

// =============================================================================
// TC014 - Invalid/Out-of-Range Address
// =============================================================================
class tc014_invalid_addr_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc014_invalid_addr_seq)

    function new(string name = "tc014_invalid_addr_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC014: Out-of-range address access", UVM_LOW)
        // Write to 64KB (beyond 4KB slave memory)
        do_write(32'h0001_0000, 32'hBAD_ADD0, 4'b1111);
        // Read from same OOR address
        do_read(32'h0001_0000);
    endtask
endclass : tc014_invalid_addr_seq

// =============================================================================
// TC015 - Stress Test (1000 transactions)
// =============================================================================
class tc015_stress_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc015_stress_seq)

    function new(string name = "tc015_stress_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(),
            $sformatf("TC015: Stress Test - %0d transactions", num_transactions), UVM_LOW)
        for (int i = 0; i < num_transactions; i++) begin
            do_rand_item();
            if (i % 100 == 0)
                `uvm_info(get_type_name(),
                    $sformatf("Stress: %0d/%0d transactions sent", i, num_transactions), UVM_LOW)
        end
    endtask
endclass : tc015_stress_seq

// =============================================================================
// TC016 - Data Patterns (All Zeros, All Ones, Walking Ones)
// =============================================================================
class tc016_data_patterns_seq extends axi4lite_base_seq;
    `uvm_object_utils(tc016_data_patterns_seq)

    function new(string name = "tc016_data_patterns_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "TC016: Data Patterns Test", UVM_LOW)
        
        // 1. All Zeros
        do_write(32'h0000_0500, 32'h0000_0000, 4'b1111);
        do_read (32'h0000_0500);

        // 2. All Ones
        do_write(32'h0000_0504, 32'hFFFF_FFFF, 4'b1111);
        do_read (32'h0000_0504);

        // 3. Walking Ones
        for (int i = 0; i < 32; i++) begin
            do_write(32'h0000_0508, 32'h0000_0001 << i, 4'b1111);
            do_read (32'h0000_0508);
        end
    endtask
endclass : tc016_data_patterns_seq

`endif // AXI4LITE_SEQUENCES_SV
