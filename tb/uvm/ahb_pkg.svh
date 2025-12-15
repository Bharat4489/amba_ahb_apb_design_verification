package ahb_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;  

    `include "tb/uvm/drivers/ahb_master_driver.svh"
    `include "tb/uvm/sequencer/ahb_master_sequencer.sv"
    `include "tb/uvm/agents/ahb_master_agent.svh"


    class my_test extends uvm_test;
        `uvm_component_utils(my_test);
        
        function new(string name= "my_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()
    endclass //my_test extends uvm_test
    
endpackage

