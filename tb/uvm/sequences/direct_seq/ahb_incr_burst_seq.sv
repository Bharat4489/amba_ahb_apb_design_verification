//seq to implement HBURST = INCR4 / INCR8 / INCR16

class ahb_incr_burst_seq extends ahb_base_sequence;
    `uvm_object_utils(ahb_incr_burst_seq)

    extern function new(string name = "ahb_incr_burst_seq");
    extern task body();

endclass //ahb_incr_burst_seq

    // -------------------------
    // NEW
function ahb_incr_burst_seq::new(string name = "ahb_incr_burst_seq");
    super.new(name);
endfunction

    // -------------------------
    // BODY
task automatic ahb_incr_burst_seq::body();
    ahb_seq_item req;   //seq_item handle
    ahb_seq_item burst_cfg;
    int offset = 32'h100;
    logic [2:0] hsize_local;
    int beat_size;
    int burst_len;


    hburst_t wrap_list[] = '{INCR4, INCR8, INCR16};

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

          burst_len = (burst_cfg.HBURST == WRAP4)  ? 4  :
                      (burst_cfg.HBURST == WRAP8)  ? 8  : 16;

          beat_size = (burst_cfg.HSIZE == BYTE)      ? 1 :
                      (burst_cfg.HSIZE == HALF_WORD) ? 2 : 4;

      finish_item(burst_cfg);

        // -------------------------
        // INCR4/8/16 burst WRITE
        // -------------------------
        for (int beat = 0; beat < burst_len; beat++) begin
            req = ahb_seq_item::type_id::create($sformatf("wrap_wr_%0d", beat));
            start_item(req);

            req.HPROT  = 4'b0001;
            req.HBURST = burst_cfg.HBURST;
            req.HSIZE  = burst_cfg.HSIZE;
            req.HTRANS = (beat == 0) ? NONSEQ : SEQ;
            req.HWRITE = 1'b1;
            req.HADDR  = burst_cfg.HADDR;
            req.HWDATA = burst_cfg.HWDATA;
            req.HLOCK  = 0;


            case (burst_cfg.HBURST)
              WRAP4  : req.pattern_id = PATTERN_WRAP4;
              WRAP8  : req.pattern_id = PATTERN_WRAP8;
              WRAP16 : req.pattern_id = PATTERN_WRAP16;
            endcase

            finish_item(req);
        end
        // -------------------------
        // INCR4/8/16 burst READ
        // -------------------------
        for (int beat = 0; beat < burst_len; beat++) begin
            req = ahb_seq_item::type_id::create($sformatf("wrap_rd_%0d", beat));
            start_item(req);

            req.HPROT  = 4'b0001;
            req.HBURST = burst_cfg.HBURST;
            req.HSIZE  = burst_cfg.HSIZE;
            req.HTRANS = (beat == 0) ? NONSEQ : SEQ;
            req.HWRITE = 1'b0;
            req.HADDR  = burst_cfg.HBURST;
            req.HLOCK  = 0;


            case (burst_cfg.HBURST)
              WRAP4  : req.pattern_id = PATTERN_WRAP4;
              WRAP8  : req.pattern_id = PATTERN_WRAP8;
              WRAP16 : req.pattern_id = PATTERN_WRAP16;
            endcase

            finish_item(req);
        end
    end
endtask
