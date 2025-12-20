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

    `uvm_info("DRIVER", "Entered run_phase", UVM_LOW)

    forever begin
        `uvm_info("DRIVER", "Waiting for item", UVM_LOW)
        seq_item_port.get_next_item(req);

        `uvm_info("DRIVER",
            $sformatf("Got item addr=%0h write=%0b", req.HADDR, req.HWRITE),
            UVM_LOW)

        // drive signals here

        seq_item_port.item_done();
        `uvm_info("DRIVER", "Item done", UVM_LOW)
    end
endtask: run_phase


