class ahb_wrap_burst_seq extends ahb_base_sequence;
  `uvm_object_utils(ahb_wrap_burst_seq)

  function new(string name = "ahb_wrap_burst_seq");
    super.new(name);
  endfunction

  task body();
    ahb_seq_item burst_cfg;
    ahb_seq_item req;

    int burst_len;
    int beat_size;
    int boundary;
    int aligned_base;
    int offset;

    // -------------------------------------------------
    // STEP-1: Randomize burst intent ONCE
    // -------------------------------------------------
    hburst_t wrap_list[] = '{WRAP4, WRAP8, WRAP16};

    foreach (wrap_list[w]) begin

      // 1. Randomize burst intent ONCE
      burst_cfg = ahb_seq_item::type_id::create("burst_cfg");
      start_item(burst_cfg);

      if (!burst_cfg.randomize() with {
              HBURST == wrap_list[w];
              HSIZE  inside {BYTE, HALF_WORD, WORD};
              HADDR  inside {[32'h0000_0000 : 32'h0000_0FFF]};
          })
          `uvm_fatal("WRAP_SEQ", "Burst intent randomization failed");

      finish_item(burst_cfg);

      // -------------------------------------------------
      // STEP-2: Derive wrap parameters
      // -------------------------------------------------
      burst_len = (burst_cfg.HBURST == WRAP4)  ? 4  :
                  (burst_cfg.HBURST == WRAP8)  ? 8  : 16;

      beat_size = (burst_cfg.HSIZE == BYTE)      ? 1 :
                  (burst_cfg.HSIZE == HALF_WORD) ? 2 : 4;

      boundary     = burst_len * beat_size;
      aligned_base = burst_cfg.HADDR & ~(boundary - 1);
      offset       = burst_cfg.HADDR - aligned_base;

      `uvm_info("ahb_wrap_burst_seq", $sformatf(
        "HBURST=%0s HSIZE=%0s HADDR=0x%0h | burst_len=%0d beat_size=%0d boundary=%0d aligned_base=0x%0h offset=%0d",
        burst_cfg.HBURST, burst_cfg.HSIZE, burst_cfg.HADDR,
        burst_len, beat_size, boundary, aligned_base, offset
      ), UVM_LOW);

      // -------------------------------------------------
      // STEP-3: Generate WRITE beats (one txn per beat)
      // -------------------------------------------------
      for (int beat = 0; beat < burst_len; beat++) begin
        req = ahb_seq_item::type_id::create($sformatf("wrap_wr_%0d", beat));
        start_item(req);

        req.HPROT  = 4'b0001;
        req.HBURST = burst_cfg.HBURST;
        req.HSIZE  = burst_cfg.HSIZE;
        req.HTRANS = (beat == 0) ? NONSEQ : SEQ;
        req.HWRITE = 1'b1;
        req.HADDR  = aligned_base +
                     ((offset + beat * beat_size) % boundary);
        req.HWDATA = burst_cfg.HWDATA;
        req.HLOCK  = 0;

        case (burst_cfg.HBURST)
          WRAP4  : req.pattern_id = PATTERN_WRAP4;
          WRAP8  : req.pattern_id = PATTERN_WRAP8;
          WRAP16 : req.pattern_id = PATTERN_WRAP16;
        endcase

        finish_item(req);
      end

      // -------------------------------------------------
      // STEP-4: Generate READ beats
      // -------------------------------------------------
      for (int beat = 0; beat < burst_len; beat++) begin
        req = ahb_seq_item::type_id::create($sformatf("wrap_rd_%0d", beat));
        start_item(req);

        req.HPROT  = 4'b0001;
        req.HBURST = burst_cfg.HBURST;
        req.HSIZE  = burst_cfg.HSIZE;
        req.HTRANS = (beat == 0) ? NONSEQ : SEQ;
        req.HWRITE = 1'b0;
        req.HLOCK  = 0;
        req.HADDR  = aligned_base +
                     ((offset + beat * beat_size) % boundary);


        case (burst_cfg.HBURST)
          WRAP4  : req.pattern_id = PATTERN_WRAP4;
          WRAP8  : req.pattern_id = PATTERN_WRAP8;
          WRAP16 : req.pattern_id = PATTERN_WRAP16;
        endcase

        finish_item(req);
      end
    end
  endtask
endclass
