class ahb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ahb_scoreboard)

    uvm_analysis_imp #(ahb_seq_item, ahb_scoreboard) analysis_imp;

    extern function new(string name = "ahb_scoreboard", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void write(ahb_seq_item t); // callback for transactions
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass : ahb_scoreboard


function ahb_scoreboard::new(string name = "ahb_scoreboard", uvm_component parent);
    super.new(name, parent);
endfunction: new

function void ahb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp = new("analysis_imp", this);
endfunction : build_phase

function void ahb_scoreboard::connect_phase(uvm_phase phase);

endfunction : connect_phase

function void ahb_scoreboard::write(ahb_seq_item t);
    `uvm_info("AHB_SCOREBOARD", $sformatf("Received item: %p", t), UVM_MEDIUM)
endfunction

task ahb_scoreboard::run_phase(uvm_phase phase);

endtask : run_phase