// =============================================================================
// File        : axi4lite_sequencer.sv
// Description : AXI4-Lite UVM Sequencer
// =============================================================================
`ifndef AXI4LITE_SEQUENCER_SV
`define AXI4LITE_SEQUENCER_SV

class axi4lite_sequencer extends uvm_sequencer #(axi4lite_seq_item);
    `uvm_component_utils(axi4lite_sequencer)

    function new(string name = "axi4lite_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass : axi4lite_sequencer

`endif // AXI4LITE_SEQUENCER_SV
