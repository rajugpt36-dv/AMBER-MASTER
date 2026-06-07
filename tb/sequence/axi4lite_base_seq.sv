// =============================================================================
// File        : axi4lite_base_seq.sv
// Description : AXI4-Lite UVM Base Sequence
//               All sequences extend this. Provides helper tasks for
//               single write, single read, write-then-read.
// =============================================================================
`ifndef AXI4LITE_BASE_SEQ_SV
`define AXI4LITE_BASE_SEQ_SV

class axi4lite_base_seq extends uvm_sequence #(axi4lite_seq_item);
    `uvm_object_utils(axi4lite_base_seq)

    // -------------------------------------------------------------------------
    // Configuration knobs accessible from all sequences
    // -------------------------------------------------------------------------
    int unsigned num_transactions = 10;
    int unsigned seq_delay        = 0;   // cycles between items (driver handles)

    // =========================================================================
    // Constructor
    // =========================================================================
    function new(string name = "axi4lite_base_seq");
        super.new(name);
    endfunction

    // =========================================================================
    // body() - to be overridden by child sequences
    // =========================================================================
    virtual task body();
        `uvm_fatal(get_type_name(), "body() not implemented in base sequence")
    endtask

    // =========================================================================
    // do_write() - helper: create and send a write seq item
    // =========================================================================
    task automatic do_write(
        input bit [31:0] addr,
        input bit [31:0] data,
        input bit [3:0]  wstrb = 4'b1111
    );
        axi4lite_seq_item item;
        `uvm_create(item)
        item.op    = AXI_WRITE;
        item.addr  = addr;
        item.data  = data;
        item.wstrb = wstrb;
        `uvm_send(item)
    endtask : do_write

    // =========================================================================
    // do_read() - helper: create and send a read seq item
    // =========================================================================
    task automatic do_read(input bit [31:0] addr);
        axi4lite_seq_item item;
        `uvm_create(item)
        item.op   = AXI_READ;
        item.addr = addr;
        item.wstrb = 4'b1111;
        `uvm_send(item)
    endtask : do_read

    // =========================================================================
    // do_rand_write() - helper: fully randomized write
    // =========================================================================
    task automatic do_rand_write();
        axi4lite_seq_item item;
        `uvm_create(item)
        if (!item.randomize() with { op == AXI_WRITE; })
            `uvm_fatal(get_type_name(), "Randomization failed for write item")
        `uvm_send(item)
    endtask : do_rand_write

    // =========================================================================
    // do_rand_read() - helper: fully randomized read
    // =========================================================================
    task automatic do_rand_read();
        axi4lite_seq_item item;
        `uvm_create(item)
        if (!item.randomize() with { op == AXI_READ; })
            `uvm_fatal(get_type_name(), "Randomization failed for read item")
        `uvm_send(item)
    endtask : do_rand_read

    // =========================================================================
    // do_rand_item() - helper: fully randomized read or write
    // =========================================================================
    task automatic do_rand_item();
        axi4lite_seq_item item;
        `uvm_create(item)
        if (!item.randomize())
            `uvm_fatal(get_type_name(), "Randomization failed for random item")
        `uvm_send(item)
    endtask : do_rand_item

endclass : axi4lite_base_seq

`endif // AXI4LITE_BASE_SEQ_SV
