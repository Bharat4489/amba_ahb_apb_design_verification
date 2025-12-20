class ahb_master_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_master_monitor)

    // Virtual interface handle for observing AHB signals
    // Monitor uses a read-only modport (no driving)
    virtual ahb_if.monitor_mp dut_vif;

    // Analysis port to send observed transactions to scoreboard/coverage
    // It is a UVM object that implements a TLM port used to broadcast transactions.
    uvm_analysis_port #(ahb_seq_item) ap;

    function new(string name = "ahb_master_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass : ahb_master_monitor

function void ahb_master_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);                   
    /*
    it is not part of the UVM component hierarchy and does not participate in phases, 
    so it is created as a regular object(but created in build phase to keep UVM construction clean and predictable
    */
    if (!uvm_config_db#(virtual ahb_if.monitor_mp)::get(this, "", "ahb_vif", dut_vif)) begin
        `uvm_fatal("NOVIF","unable to get virtual intf from uvm_config_d")
    end
endfunction //ahb_master_monitor::build_phase

task ahb_master_monitor::run_phase(uvm_phase phase);
    //ap.write(txn);       // “I am publishing this transaction to whoever is connected.”
endtask //ahb_master_monitor::run_phase