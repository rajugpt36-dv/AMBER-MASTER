// =============================================================================
// File        : axi4lite_config.sv
// Description : AXI4-Lite UVM Agent Configuration Object
// =============================================================================
`ifndef AXI4LITE_CONFIG_SV
`define AXI4LITE_CONFIG_SV

class axi4lite_config extends uvm_object;

    // -------------------------------------------------------------------------
    // Agent mode
    // -------------------------------------------------------------------------
    uvm_active_passive_enum is_active    = UVM_ACTIVE;
    bit                     has_coverage = 1;

    // -------------------------------------------------------------------------
    // Driver timing
    // -------------------------------------------------------------------------
    int unsigned aw_wait_states  = 0;
    int unsigned w_wait_states   = 0;
    int unsigned ar_wait_states  = 0;
    int unsigned max_wait_cycles = 256;
    int unsigned inter_txn_delay = 0;

    `uvm_object_utils_begin(axi4lite_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_int(has_coverage,       UVM_ALL_ON)
        `uvm_field_int(aw_wait_states,     UVM_ALL_ON)
        `uvm_field_int(w_wait_states,      UVM_ALL_ON)
        `uvm_field_int(ar_wait_states,     UVM_ALL_ON)
        `uvm_field_int(max_wait_cycles,    UVM_ALL_ON)
        `uvm_field_int(inter_txn_delay,    UVM_ALL_ON)
    `uvm_object_utils_end

    // -------------------------------------------------------------------------
    // Virtual interface handle
    // -------------------------------------------------------------------------
    virtual axi4lite_if vif;

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------
    function new(string name = "axi4lite_config");
        super.new(name);
    endfunction

endclass : axi4lite_config

`endif // AXI4LITE_CONFIG_SV
