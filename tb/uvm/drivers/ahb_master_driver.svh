//instead of using RTL master, we are driving sequence using UVM tb

class ahb_master_driver extends uvm_driver #(uvm_sequence_item);
    `uvm_component_utils(ahb_master_driver)

    virtual ahb_if.master_mp dut_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    extern function void build_phase(uvm_phase phase);
    extern task run_phase (uvm_phase phase);
endclass //ahb_master_driver extends uvm_driver

function ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if.master_mp)::get(this, "", "ahb_vif", dut_vif)) begin  //not checking null== dut_vif, as we are getting it here from config database
            `uvm_fatal("NOVIF","unable to get virtual intf from uvm_config_db")
        end  
endfunction

task ahb_master_driver::run_phase(uvm_phase phase);
    //
endtask : run_phase



