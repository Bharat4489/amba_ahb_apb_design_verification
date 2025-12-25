//instead of using RTL master, we are driving sequence using UVM tb

class ahb_master_driver extends uvm_driver #(ahb_seq_item);
    `uvm_component_utils(ahb_master_driver)

    virtual ahb_if.master_mp dut_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    extern function void build_phase(uvm_phase phase);
    extern task run_phase (uvm_phase phase);
    extern task automatic drive_control (ahb_seq_item req_current);
    extern task automatic drive_data (ahb_seq_item req_current);
endclass : ahb_master_driver

function void ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if.master_mp)::get(this, "", "ahb_vif", dut_vif)) begin  //not checking null== dut_vif, as we are getting it here from config database
            `uvm_fatal("DRIVER:NOVIF","unable to get VIF from uvm_config_db")
        end
endfunction : build_phase


task ahb_master_driver::run_phase(uvm_phase phase);
  ahb_seq_item req_current, req_next;
  bit have_next=0;

  `uvm_info("DRIVER", "Entered run_phase", UVM_MEDIUM)

  wait (dut_vif.driver_cb.HRESETn === 1'b1);                    // Wait for reset deassertion before doing anything
  `uvm_info("DRIVER", "Reset deasserted; starting bus traffic", UVM_MEDIUM)

  seq_item_port.get_next_item(req_current);                    //fetching current req

  forever begin
    @(dut_vif.driver_cb);
    drive_control(req_current);                                 //CONTROL PHASE START AS SOON AS THERE IS A SEQ_ITEM AVAILABLE
    `uvm_info("DRIVER", $sformatf("drive_control(current): HADDR=0x%08h HSIZE=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h",
            req_current.HADDR, req_current.HSIZE, req_current.HTRANS, req_current.HWRITE, req_current.HWDATA), UVM_MEDIUM)
    if(have_next) begin
        while(!dut_vif.driver_cb.HREADY) @(dut_vif.driver_cb);                                   //HREADY WILL START DATA PHASE
        drive_data(req_next);
        `uvm_info("DRIVER", $sformatf("drive_data(next): HADDR=0x%08h HSIZE=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h",
            req_next.HADDR, req_next.HSIZE, req_next.HTRANS, req_next.HWRITE, req_current.HWDATA), UVM_MEDIUM)
        have_next = 0;
        seq_item_port.item_done(req_next);
        `uvm_info("DRIVER", "req_next: Item done", UVM_MEDIUM)
    end

    do @(dut_vif.driver_cb);                                                //add one cycle delay as control phase is one cycle minimum
    while(!dut_vif.driver_cb.HREADY);                                       //HREADY WILL START DATA PHASE
    drive_data(req_current);
    `uvm_info("DRIVER", $sformatf("drive_data(current): HADDR=0x%08h HSIZE=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h",
            req_current.HADDR, req_current.HSIZE, req_current.HTRANS, req_current.HWRITE, req_current.HWDATA), UVM_MEDIUM)

    seq_item_port.item_done(req_current);                                   //transaction complete
    `uvm_info("DRIVER", "req_current: Item done", UVM_MEDIUM)

    if (!have_next && seq_item_port.has_do_available()) begin               //check if there is next txn in sequence for pipelining
        seq_item_port.try_next_item(req_next);
        have_next = 1;
        if (have_next) begin                                                //fetch txn for next cycle
            //seq_item_port.get_next_item(req_next);
            drive_control(req_next);
            `uvm_info("DRIVER", $sformatf("drive_control(next): HADDR=0x%08h HSIZE=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h",
                req_next.HADDR, req_next.HSIZE, req_next.HTRANS, req_next.HWRITE, req_current.HWDATA), UVM_MEDIUM)
        end
    end
    seq_item_port.get_next_item(req_current);

  end
endtask : run_phase


task automatic ahb_master_driver::drive_control(ahb_seq_item req_current);
    dut_vif.driver_cb.HWRITE  <= req_current.HWRITE;
    dut_vif.driver_cb.HTRANS  <= req_current.HTRANS;
    dut_vif.driver_cb.HSIZE   <= req_current.HSIZE;
    dut_vif.driver_cb.HADDR   <= req_current.HADDR;

endtask : drive_control

task automatic ahb_master_driver::drive_data(ahb_seq_item req_current);
    if(dut_vif.driver_cb.HWRITE)
        dut_vif.driver_cb.HWDATA  <= req_current.HWDATA;
endtask : drive_data
