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
  `uvm_info("MONITOR", "Monitor run_phase entered", UVM_MEDIUM)

  // Guard against missing virtual interface
  if (dut_vif == null)
    `uvm_fatal("MONITOR:NOVIF", "monitor VIF is null; check config_db set/get keys")

  forever begin
    @(dut_vif.monitor_cb);   //    This avoids races compared to using 'wait(...)' alone.
    // 2) Address/Control phase detect:
    //    Valid transfer when HREADY==1 and HTRANS is NONSEQ(2'b10) or SEQ(2'b11).
    if (dut_vif.monitor_cb.HREADY &&
        (dut_vif.monitor_cb.HTRANS inside {2'b10, 2'b11})) begin

      // Create a fresh transaction object BEFORE assigning fields (avoid TRNULLID).
      ahb_seq_item txn = ahb_seq_item::type_id::create("txn", this);

      // Sample address/control on the address-phase edge.
      txn.HTRANS   = dut_vif.monitor_cb.HTRANS;
      txn.HWRITE   = dut_vif.monitor_cb.HWRITE;
      txn.HADDR    = dut_vif.monitor_cb.HADDR;
      txn.HSIZE    = dut_vif.monitor_cb.HSIZE;
      txn.HBURST   = dut_vif.monitor_cb.HBURST;
      txn.HPROT    = dut_vif.monitor_cb.HPROT;
      txn.HREADY   = dut_vif.monitor_cb.HREADY;
      txn.HWDATA   = dut_vif.monitor_cb.HWDATA; 
      txn.HBUSREQ  = dut_vif.monitor_cb.HBUSREQ; // keep only if you model arbitration

      // 3) Data-phase handshake:
      //    Respect AHB wait-states—data phase completes when HREADY goes high again.
      //    Using do..while on the clocking block keeps us edge-aligned.
      do @(dut_vif.monitor_cb); while (!dut_vif.monitor_cb.HREADY);

      // Sample the data when the data phase completes.
      if (txn.HWRITE)
        txn.HWDATA = dut_vif.monitor_cb.HWDATA;
      else
        txn.HRDATA = dut_vif.monitor_cb.HRDATA;

      `uvm_info("MONITOR:", txn.sprint(), UVM_LOW)

      // 4) Publish this single beat to the analysis network.
      ap.write(txn);
      `uvm_info("MONITOR", "Transaction sent to scoreboard", UVM_MEDIUM)
    end
    // If condition is not met, loop back on next clock; monitor remains passive.
  end // forever
endtask
