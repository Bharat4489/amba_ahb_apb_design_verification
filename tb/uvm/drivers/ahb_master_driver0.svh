//instead of using RTL master, we are driving sequence using UVM tb

//NOTE: AS OF NOW PIPELINING IS NOT WORKING, NEED TO LOOK AT IT LATER
//NOTE: HTRANS IS NOT SEQ, AS OF NOW SINGLE BEAT ASSUMPTION IS THERE
class ahb_master_driver0 extends uvm_driver #(ahb_seq_item);
    `uvm_component_utils(ahb_master_driver0)

    virtual ahb_if.master_mp dut_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    extern function void build_phase(uvm_phase phase);

    bit first_beat;   //to assign HTRANS signal values
    extern task run_phase (uvm_phase phase);
    extern task automatic drive_control (ahb_seq_item req_current);
    extern task automatic drive_data (ahb_seq_item req_current);
endclass : ahb_master_driver0

    // -------------------------
    // BUILD PHASE 
function void ahb_master_driver0::build_phase(uvm_phase phase);
    super.build_phase(phase);
        if (!uvm_config_db#(virtual ahb_if.master_mp)::get(this, "", "ahb_vif", dut_vif)) begin  //not checking null== dut_vif, as we are getting it here from config database
            `uvm_fatal("DRIVER:NOVIF","unable to get VIF from uvm_config_db")
        end
endfunction : build_phase

    // -------------------------
    // RUN PHASE
task ahb_master_driver0::run_phase(uvm_phase phase);
  ahb_seq_item req_current;

  wait (dut_vif.driver_cb.HRESETn === 1'b1);

  forever begin
    // Get transaction
    seq_item_port.get_next_item(req_current);

    // Request bus
    dut_vif.driver_cb.HBUSREQ[0] <= 1'b1;
    first_beat = 1'b1;

    // Wait for grant
    do @(dut_vif.driver_cb);
    while (!dut_vif.driver_cb.HGRANT[0]);

    // Address phase
    @(dut_vif.driver_cb);
    drive_control(req_current);

    // Data phase (wait-state aware)
    do @(dut_vif.driver_cb);
    while (!dut_vif.driver_cb.HREADY);

    drive_data(req_current);

    // Complete transaction
    seq_item_port.item_done();

    // Release bus
    dut_vif.driver_cb.HBUSREQ[0] <= 1'b0;
  end
endtask

    // -------------------------
    // DRIVER CONTROL
task automatic ahb_master_driver0::drive_control(ahb_seq_item req_current);
  dut_vif.driver_cb.HWRITE <= req_current.HWRITE;
  dut_vif.driver_cb.HSIZE  <= req_current.HSIZE;
  dut_vif.driver_cb.HADDR  <= req_current.HADDR;

  // Bubble-safe master: every transfer is NONSEQ
  dut_vif.driver_cb.HTRANS <= NONSEQ;
endtask : drive_control


    // -------------------------
    // DRIVE DATA
task automatic ahb_master_driver0::drive_data(ahb_seq_item req_current);
    if(dut_vif.driver_cb.HWRITE)
        dut_vif.driver_cb.HWDATA  <= req_current.HWDATA;
endtask : drive_data


