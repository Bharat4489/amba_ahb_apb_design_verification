`timescale 1ns/1ps

package ahb_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*; 
    import ahb_params_pkg::*;

    `include "tb/uvm/sequence_item/ahb_base_seq_item.svh"
    `include "tb/uvm/sequence_item/ahb_seq_item.svh"
    `include "tb/uvm/drivers/ahb_master_driver.svh"
    `include "tb/uvm/sequences/ahb_base_sequence.svh"
    `include "tb/uvm/sequences/ahb_direct_sequences/multiple_write_read_seq.svh"
    `include "tb/uvm/sequencer/ahb_master_sequencer.svh"
    `include "tb/uvm/monitors/ahb_master_monitor.svh"
    `include "tb/uvm/agents/ahb_master_agent.svh"
    `include "tb/uvm/scoreboard/ahb_scoreboard.svh"
    `include "tb/uvm/env/ahb_env.svh"
    `include "tb/tests/my_test.svh"
    `include "tb/tests/my_directed_test.svh"

    virtual ahb_if if1;

    task set_pattern_name(string msg);  //need to be improved later
        if (!uvm_config_db#(virtual ahb_if)::get(null, "", "ahb_vif", if1)) begin
          `uvm_fatal("ahb_base_sequence","Unable to get virtual if for SEQUENCE. Have you set it properly?")
        end
      if1.pattern_name = msg;
      ->if1.pattern_update;
    endtask: set_pattern_name
endpackage
