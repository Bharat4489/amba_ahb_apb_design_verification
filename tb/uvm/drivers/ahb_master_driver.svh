//instead of using RTL master, we are driving sequence using UVM tb

class ahb_master_driver extends uvm_driver #(ahb_seq_item);
    `uvm_component_utils(ahb_master_driver)

    virtual ahb_if.master_mp dut_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    extern function void build_phase(uvm_phase phase);
    extern task run_phase (uvm_phase phase);
endclass //ahb_master_driver extends uvm_driver

function void ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if.master_mp)::get(this, "", "ahb_vif", dut_vif)) begin  //not checking null== dut_vif, as we are getting it here from config database
            `uvm_fatal("DRIVER:NOVIF","unable to get VIF from uvm_config_db")
        end  
endfunction


task ahb_master_driver::run_phase(uvm_phase phase);
  ahb_seq_item req;

  phase.raise_objection(this);
  `uvm_info("DRIVER", "Entered run_phase", UVM_LOW)

  // Wait for reset deassertion before doing anything
  wait (dut_vif.cb.HRESETn === 1'b1);
  `uvm_info("DRIVER", "Reset deasserted; starting bus traffic", UVM_LOW)

  forever begin
    `uvm_info("DRIVER", "Waiting for item", UVM_LOW)
    seq_item_port.get_next_item(req);

    `uvm_info("DRIVER",
      $sformatf("Got item addr=%0h write=%0b", req.HADDR, req.HWRITE),
      UVM_LOW)

    // ----- ADDRESS PHASE (on next clock edge) -----
    @(dut_vif.cb);  // posedge HCLK via clocking block

    dut_vif.cb.HSEL   <= 1'b1;
    dut_vif.cb.HTRANS <= 2'b10;           // NONSEQ
    dut_vif.cb.HWRITE <= req.HWRITE;
    dut_vif.cb.HADDR  <= req.HADDR;

    // ----- DATA PHASE HANDSHAKE -----
    // AHB advances when HREADY is high; wait for it
    do @(dut_vif.cb); while (dut_vif.cb.HREADY !== 1'b1);

    // (If write, you would also drive HWDATA here in your full interface)
    // For read, you'd sample HRDATA with dut_vif.cb at data phase end.

    // ----- COMPLETE THE BEAT -----
    dut_vif.cb.HSEL   <= 1'b0;
    dut_vif.cb.HTRANS <= 2'b00;           // IDLE

    // Return the item to the sequencer
    seq_item_port.item_done();

    `uvm_info("DRIVER", "Item done", UVM_LOW)
  end

  phase.drop_objection(this);
endtask
