`timescale 1ns/1ps

package ahb_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*; 
    import ahb_params_pkg::*;

    `include "tb/uvm/sequence_item/ahb_base_seq_item.svh"
    `include "tb/uvm/sequence_item/ahb_seq_item.svh"
    `include "tb/uvm/drivers/ahb_master_driver.svh"
    `include "tb/uvm/sequences/ahb_base_sequence.svh"
    `include "tb/uvm/sequencer/ahb_master_sequencer.svh"
    `include "tb/uvm/monitors/ahb_master_monitor.svh"
    `include "tb/uvm/agents/ahb_master_agent.svh"
    `include "tb/uvm/scoreboard/ahb_scoreboard.svh"
    `include "tb/uvm/env/ahb_env.svh"

    class my_test extends uvm_test;
        `uvm_component_utils(my_test)

        ahb_env env;

        function new(string name="my_test", uvm_component parent=null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = ahb_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            ahb_base_sequence seq;
            `uvm_info("MY_TEST", "RAISING OBJECTION", UVM_LOW)
            phase.raise_objection(this);

            seq = ahb_base_sequence::type_id::create("seq");
            `uvm_info("MY_TEST", "STARTING SEQUENCE", UVM_LOW)
            seq.start(env.m_ahb_agent.m_ahb_sequencer);

            #100;
            `uvm_info("MY_TEST", "DROPPING OBJECTION", UVM_LOW)
            phase.drop_objection(this);
        endtask
    endclass

    
endpackage
