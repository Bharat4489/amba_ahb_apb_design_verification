//instead of using RTL master, we are driving sequence using UVM tb

class ahb_master_driver extends uvm_driver #(ahb_seq_item);
    `uvm_component_utils(ahb_master_driver)

    virtual ahb_if.master_mp dut_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    extern function void build_phase(uvm_phase phase);
    extern task run_phase (uvm_phase phase);
    extern task send_to_dut (ahb_seq_item req);
endclass //ahb_master_driver extends uvm_driver

function void ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if.master_mp)::get(this, "", "ahb_vif", dut_vif)) begin  //not checking null== dut_vif, as we are getting it here from config database
            `uvm_fatal("DRIVER:NOVIF","unable to get VIF from uvm_config_db")
        end  
endfunction


task ahb_master_driver::run_phase(uvm_phase phase);
  ahb_seq_item req;

  `uvm_info("DRIVER", "Entered run_phase", UVM_LOW)

  // Wait for reset deassertion before doing anything
  wait (dut_vif.driver_cb.HRESETn === 1'b1);
  `uvm_info("DRIVER", "Reset deasserted; starting bus traffic", UVM_LOW)

  forever begin
    `uvm_info("DRIVER", "Waiting for item", UVM_LOW)
    seq_item_port.get_next_item(req);
    `uvm_info("DRIVER", req.sprint(), UVM_LOW)
    send_to_dut(req);
    seq_item_port.item_done();
    `uvm_info("DRIVER", "Item done", UVM_LOW)
  end
endtask

task ahb_master_driver::send_to_dut(ahb_seq_item req);
  //drive addr and control info
    @(dut_vif.driver_cb);
        dut_vif.driver_cb.HWRITE  <= req.HWRITE;
        dut_vif.driver_cb.HTRANS  <= 2'b10; //NONSEQ
        dut_vif.driver_cb.HSIZE   <= req.HSIZE;
        dut_vif.driver_cb.HADDR   <= req.HADDR;
        // dut_vif.driver_cb.HREADY  <= req.HREADY; //HREADY is send by slave

    @(dut_vif.driver_cb); // One-cycle transfer assumption (no wait states yet)   -AFTER ADDING SLAVE WE WILL USE HREADY to deassert HTRANS
        dut_vif.driver_cb.HTRANS <= 2'b00;  // Return bus to IDLE 
endtask /send_to_dut
