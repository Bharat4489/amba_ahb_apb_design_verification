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
    `uvm_info("MON", "Monitor run_phase entered", UVM_LOW)
    // Monitor runs forever, passively sampling the bus every cycle
    forever begin
      @(posedge dut_vif.HCLK);

      // Only capture transactions when:
      // 1. Reset is deasserted (bus is active)
      // 2. HTRANS indicates a NONSEQ transfer (valid address phase)
      // This avoids collecting spurious or idle bus activity
      if (dut_vif.HRESETn && dut_vif.HTRANS == 2'b10) begin
        txn = ahb_seq_item::type_id::create("txn", this); //transaction-level abstraction of pin-level activity
        txn.HADDR  = dut_vif.HADDR;
        txn.HWRITE = dut_vif.HWRITE;
        txn.HTRANS = dut_vif.HTRANS;
        // Publish the transaction to the analysis network, ap.write() does NOT call write() directly;
        // UVM routes this transaction to all connected analysis_imps (e.g., scoreboard, coverage, reference models)
        `uvm_info("MON", "Observed valid transfer", UVM_LOW)
        ap.write(txn);
        `uvm_info("MON", "Transaction sent to scoreboard", UVM_LOW)
      end
    end
endtask
