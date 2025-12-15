
class ahb_master_sequencer extends uvm_sequencer#(uvm_sequence_item);
    `uvm_component_utils(ahb_master_sequencer)

    function new(string name = "ahb_master_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction //new()
    
endclass //ahb_master_sequencer extends uvm_sequencer