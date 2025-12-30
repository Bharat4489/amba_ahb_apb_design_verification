//instead of using RTL master, we are driving sequence using UVM tb

//NOTE: AS OF NOW PIPELINING IS NOT WORKING, NEED TO LOOK AT IT LATER
//NOTE: HTRANS IS NOT SEQ, AS OF NOW SINGLE BEAT ASSUMPTION IS THERE
class ahb_master_driver extends uvm_driver #(ahb_seq_item);
    `uvm_component_utils(ahb_master_driver)

    virtual ahb_if.master_mp dut_vif;

    function new(string name = "ahb_master_driver", uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    ahb_agent_cfg m_agent_cfg;

    extern function void build_phase(uvm_phase phase);

    extern task run_phase (uvm_phase phase);
    extern task automatic drive_control (ahb_seq_item req);
    extern task automatic drive_data (ahb_seq_item req);
endclass : ahb_master_driver

    // -------------------------
    // BUILD PHASE
function void ahb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER", "Entered build_phase", UVM_MEDIUM)

        if(!uvm_config_db#(ahb_agent_cfg)::get(this, "", "ahb_agent_cfg", m_agent_cfg))
            `uvm_fatal("NO_CFG", "unable to get agent cfg, have you set it?")

        if (!uvm_config_db#(virtual ahb_if.master_mp)::get(this, "", "ahb_vif", dut_vif)) begin  //not checking null== dut_vif, as we are getting it here from config database
            `uvm_fatal("DRIVER:NOVIF","unable to get VIF from uvm_cfg_db")
        end
endfunction : build_phase

    // -------------------------
    // RUN PHASE
task ahb_master_driver::run_phase(uvm_phase phase);
      ahb_seq_item req;
      `uvm_info("DRIVER", "Entered run_phase", UVM_MEDIUM)

      wait (dut_vif.driver_cb.HRESETn === 1'b1);
      dut_vif.driver_cb.HLOCK[int'(m_agent_cfg.master_id)] <= 0;

      forever begin
        // Get transaction
        seq_item_port.get_next_item(req);               //get next transaction to drive on interface
        dut_vif.driver_cb.master_id <= m_agent_cfg.master_id;   //set master_id on iterface
        req.master_id = m_agent_cfg.master_id;          //get master_id for MASTER based signals e.g. HBUSREQ, HLOCK

        // Request bus
        dut_vif.driver_cb.HBUSREQ[int'(req.master_id)] <= 1'b1;
        //HLOCKx must be asserted at least a cycle before the address to which it refers(pdf:3-28)
        dut_vif.driver_cb.HLOCK[int'(req.master_id)] <= req.HLOCK;
        // Wait for grant
        while (!dut_vif.driver_cb.HGRANT[req.master_id]) begin
          @(dut_vif.driver_cb); // wait one clocking event
        end

        // Address phase
        @(dut_vif.driver_cb);
        drive_control(req);

        //Address accepted->Release bus
        if (dut_vif.driver_cb.HREADY) begin
            dut_vif.driver_cb.HBUSREQ[int'(req.master_id)] <=   1'b0;
        end

        // Data phase (wait-state aware)
        do @(dut_vif.driver_cb);
        while (!dut_vif.driver_cb.HREADY);

        drive_data(req);

        //end transfer properly
        dut_vif.driver_cb.HTRANS <= IDLE;
        dut_vif.driver_cb.HLOCK[int'(req.master_id)] <= 1'b0;
        // Complete transaction
        seq_item_port.item_done();
        `uvm_info("DRIVER",
                $sformatf("HADDR=0x%08h HSIZE=%0d HLOCK=%0d HBURST=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h HREADY=%0b HBUSREQ=%0b HPROT=%0b",
                    dut_vif.driver_cb.HADDR,    dut_vif.driver_cb.HSIZE,
                    dut_vif.driver_cb.HLOCK[int'(m_agent_cfg.master_id)],
                    dut_vif.driver_cb.HBURST,   dut_vif.driver_cb.HTRANS,
                    dut_vif.driver_cb.HWRITE,   dut_vif.driver_cb.HWDATA,
                    dut_vif.driver_cb.HREADY,   dut_vif.driver_cb.HBUSREQ[int'(m_agent_cfg.master_id)],
                    dut_vif.driver_cb.HPROT
                    ),
                UVM_MEDIUM
                );
        // Release bus
        dut_vif.driver_cb.HBUSREQ[int'(req.master_id)] <= 1'b0;
      end
endtask

    // -------------------------
    // DRIVER CONTROL
task automatic ahb_master_driver::drive_control(ahb_seq_item req);
  dut_vif.driver_cb.HWRITE <= req.HWRITE;
  dut_vif.driver_cb.HSIZE  <= req.HSIZE;
  dut_vif.driver_cb.HADDR  <= req.HADDR;
  dut_vif.driver_cb.HBURST <= req.HBURST;
  dut_vif.driver_cb.HTRANS <= req.HTRANS;
  dut_vif.driver_cb.HPROT  <= req.HPROT;
endtask : drive_control


    // -------------------------
    // DRIVE DATA
task automatic ahb_master_driver::drive_data(ahb_seq_item req);
    if(dut_vif.driver_cb.HWRITE)
        dut_vif.driver_cb.HWDATA  <= req.HWDATA;
endtask : drive_data

