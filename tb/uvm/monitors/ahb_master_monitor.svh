class ahb_master_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_master_monitor)

    // Virtual interface handle for observing AHB signals
    // Monitor uses a read-only modport (no driving)
    virtual ahb_if.monitor_mp dut_vif;

    // Analysis port to send observed transactions to scoreboard/coverage
    // It is a UVM object that implements a TLM port used to broadcast transactions.
    uvm_analysis_port #(ahb_seq_item) ap;

    function new(string name = "ahb_master_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass : ahb_master_monitor

  // ------------------------------------------------------------------
  // build_phase
  // ------------------------------------------------------------------
function void ahb_master_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);                   
    /*
    TLM ports not part of the UVM component hierarchy and does not participate in phases, 
    so TLM ports created as a regular object(but created in build phase to keep UVM construction clean and predictable
    */
    if (!uvm_config_db#(virtual ahb_if.monitor_mp)::get(this, "", "ahb_vif", dut_vif)) begin
        `uvm_fatal("MONITOR:NOVIF","unable to get VIF from uvm_config_db")
    end
endfunction //ahb_master_monitor::build_phase

  // ------------------------------------------------------------------
  // run_phase
  // ------------------------------------------------------------------
task ahb_master_monitor::run_phase(uvm_phase phase);
    ahb_seq_item txn;
    `uvm_info("MONITOR", "Monitor run_phase entered", UVM_MEDIUM)
    // Monitor runs forever, passively sampling the bus every cycle
    forever begin
      wait(dut_vif.cb.HREADY && (dut_vif.cb.HTRANS=='b10 || dut_vif.cb.HTRANS=='b11))
          txn.HTRANS = dut_vif.cb.HTRANS;
          txn.HWRITE = dut_vif.cb.HWRITE;
          txn.HADDR = dut_vif.cb.HADDR; 
          txn.HREADY = dut_vif.cb.HREADY;
          txn.HSIZE = dut_vif.cb.HSIZE;              
          txn.HBURST = dut_vif.cb.HBURST;          
          txn.HPROT = dut_vif.cb.HPROT;      
          txn.HWDATA = dut_vif.cb.HWDATA;         
          txn.HBUSREQ = dut_vif.cb.HBUSREQ;                                 
        
      @(dut_vif.cb.monitor_mp);

      wait(dut_vif.cb.HREADY && (dut_vif.cb.HTRANS=='b10 || dut_vif.cb.HTRANS=='b11))
        if(dut_vif.cb.HWRITE)
          txn.HWDATA = dut_vif.cb.HWDATA;
        else 
          txn.HRDATA = dut_vif.cb.HRDATA;

        txn.print();
        // Publish the transaction to the analysis network, ap.write() does NOT call write() directly;
        // UVM routes this transaction to all connected analysis_imps (e.g., scoreboard, coverage, reference models)
        `uvm_info("MONITOR", "Observed valid transfer", UVM_MEDIUM)
        ap.write(txn);
        `uvm_info("MONITOR", "Transaction sent to scoreboard", UVM_MEDIUM)
      end
endtask
