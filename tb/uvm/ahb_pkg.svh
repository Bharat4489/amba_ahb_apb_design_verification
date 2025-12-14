package ahb_pkg
    `include "uvm_macros.svh"
    import uvm_pkg::*;  

    class my_test extends uvm_test;
        `uvm_component_utils(my_test);
        
        function new(string name= "my_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()


    endclass //my_test extends uvm_test
endpackage
