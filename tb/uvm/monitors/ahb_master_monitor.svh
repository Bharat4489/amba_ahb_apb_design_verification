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
  `uvm_info("MONITOR", "Entered run_phase", UVM_MEDIUM)

  // Guard against missing virtual interface
  if (dut_vif == null)
    `uvm_fatal("MONITOR:NOVIF", "monitor VIF is null; check config_db set/get keys")

  // Do nothing while reset is asserted
  wait (dut_vif.monitor_cb.HRESETn);

  forever begin
    // Sample at the clocking-block edge (avoids races)
    @(dut_vif.monitor_cb);

    // Skip if reset glitched back
    if (!dut_vif.monitor_cb.HRESETn)
      continue;

    // ----------------------------
    // ADDRESS PHASE: detect valid beat
    // ----------------------------
    if (dut_vif.monitor_cb.HREADY &&
        (dut_vif.monitor_cb.HTRANS inside {NONSEQ, SEQ})) begin

      // Create txn only when a valid address phase is detected
      ahb_seq_item txn = ahb_seq_item::type_id::create("txn");

      // Capture address/control (address phase)
      txn.HTRANS = dut_vif.monitor_cb.HTRANS;
      txn.HWRITE = dut_vif.monitor_cb.HWRITE;
      txn.HADDR  = dut_vif.monitor_cb.HADDR;
      txn.HSIZE  = dut_vif.monitor_cb.HSIZE;
      txn.HBURST = dut_vif.monitor_cb.HBURST;
      txn.HPROT  = dut_vif.monitor_cb.HPROT;
      txn.HSEL_DEFAULT = dut_vif.monitor_cb.HSEL_DEFAULT;
      txn.HSEL_SRAM    = dut_vif.monitor_cb.HSEL_SRAM;

      // ----------------------------
      // DATA PHASE: wait until beat completes (handle wait-states)
      // ----------------------------
      do begin
        @(dut_vif.monitor_cb);
        if (!dut_vif.monitor_cb.HRESETn) begin
          // Reset mid-transfer: drop the transaction; don't publish
          txn = null;
          break;
        end
      end while (!dut_vif.monitor_cb.HREADY);

      if (txn != null) begin
        // Sample data & response at data-phase completion
        if (txn.HWRITE)
          txn.HWDATA = dut_vif.monitor_cb.HWDATA;
        else
          txn.HRDATA = dut_vif.monitor_cb.HRDATA;

        txn.HRESP  = dut_vif.monitor_cb.HRESP;
        txn.HREADY = dut_vif.monitor_cb.HREADY; // will be 1 here

        `uvm_info("MONITOR",
          $sformatf("HADDR=0x%08h HSIZE=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h HRDATA=0x%08h HREADY=%0b HSEL_DEFAULT=%0b HSEL_SRAM=%0b HRESP=%0d",
                    txn.HADDR, txn.HSIZE, txn.HTRANS, txn.HWRITE,
                    txn.HWRITE ? txn.HWDATA : '0,
                    txn.HWRITE ? '0 : txn.HRDATA,
                    txn.HREADY,
                    txn.HSEL_DEFAULT,
                    txn.HSEL_SRAM,
                    txn.HRESP),
          UVM_MEDIUM)

        // ----------------------------
        // PUBLISH: only after data-phase completion
        // ----------------------------
        txn_cnt++;

      dut_vif.AHB_TXN_INFO = $sformatf(
        "[%0d] %s %s %s %s %s A=0x%08h D=0x%08h",
        txn_cnt,
        txn.seq_name,

        // HBURST decode
        (txn.HBURST == INCR)   ? "INCR"   :
        (txn.HBURST == INCR4)  ? "INCR4"  :
        (txn.HBURST == INCR8)  ? "INCR8"  :
        (txn.HBURST == INCR16) ? "INCR16" :
        (txn.HBURST == WRAP4)  ? "WRAP4"  :
        (txn.HBURST == WRAP8)  ? "WRAP8"  :
        (txn.HBURST == WRAP16) ? "WRAP16" : "UNK",

        // HSIZE decode
        (txn.HSIZE == BYTE)      ? "BYTE" :
        (txn.HSIZE == HALF_WORD) ? "HWORD":
        (txn.HSIZE == WORD)      ? "WORD" : "UNK",

        // HTRANS decode
        (txn.HTRANS == NONSEQ) ? "NONSEQ" :
        (txn.HTRANS == SEQ)    ? "SEQ"    : "OTH",

        // READ / WRITE
        txn.HWRITE ? "WRITE" : "READ",

        txn.HADDR,

        // Data (show WDATA for write, RDATA for read)
        txn.HWRITE ? txn.HWDATA : txn.HRDATA
      );

        ap.write(txn);
      end
      // else: reset hit mid-transfer; nothing to publish
    end
    // else: IDLE/BUSY or not yet accepted → ignore
  end // forever
endtask

