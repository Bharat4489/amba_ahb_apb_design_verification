// HBURST(=>burst_len)= INCR4 / INCR8 / INCR16
// HSIZE (=>beat_size) = BYTE(1), HALF_WORD(2), WORD(4) bytes
// AHB uses byte addressing
// WRAP boundary = burst_len × beat_size
// Total combinations = 3 × 3 = 9
// Boundaries (bytes):
// INCR4 :  4,  8, 16
// INCR8 :  8, 16, 32
// INCR16: 16, 32, 64
//aligned_base = (base & ~(boundary - 1))
//offset = req.HADDR-aligned_base
//WRAP_ADDR = aligned_base + ((offset + beat) % boundary)


class ahb_wrap_burst_seq extends ahb_base_sequence;
    `uvm_object_utils(ahb_wrap_burst_seq)

    extern function new(string name = "ahb_wrap_burst_seq");
    extern task body();
endclass //ahb_wrap_burst_seq extends ahb_base_sequence

    // -------------------------
    // NEW
function ahb_wrap_burst_seq::new(string name = "ahb_wrap_burst_seq");
    super.new(name);
endfunction

    // -------------------------
    // BODY
task ahb_wrap_burst_seq::body();
    ahb_seq_item burst_cfg;
    ahb_seq_item req;

    int burst_len;
    int beat_size;
    int boundary;
    int aligned_base;
    int offset;

    // -------------------------------------------------
    // Step-1: Randomize WRAP burst intent ONCE
    // -------------------------------------------------
    burst_cfg = ahb_seq_item::type_id::create("burst_cfg");

    if (!burst_cfg.randomize() with {
        HBURST inside {WRAP4, WRAP8, WRAP16};
        HSIZE  inside {BYTE, HALF_WORD, WORD};
        HADDR  inside {[32'h0000_0000 : 32'h0000_FFFF]};
    })
        `uvm_fatal("ahb_wrap_burst_seq", "Burst intent randomization failed");

    // -------------------------------------------------
    // Step-2: Derive parameters
    // -------------------------------------------------
    burst_len = (burst_cfg.HBURST == WRAP4)  ? 4  :
                (burst_cfg.HBURST == WRAP8)  ? 8  : 16;

    beat_size = (burst_cfg.HSIZE == BYTE)      ? 1 :
                (burst_cfg.HSIZE == HALF_WORD) ? 2 : 4;

    boundary     = burst_len * beat_size;
    aligned_base = burst_cfg.HADDR & ~(boundary - 1);
    offset       = burst_cfg.HADDR - aligned_base;

    // -------------------------------------------------
    // Step-3: WRAP WRITE burst
    // -------------------------------------------------
    for (int i = 0; i < burst_len; i++) begin
        req = ahb_seq_item::type_id::create($sformatf("wrap_wr_%0d", i));

        start_item(req);

        req.HBURST = burst_cfg.HBURST;
        req.HSIZE  = burst_cfg.HSIZE;
        req.HWRITE = 1'b1;
        req.HADDR  = aligned_base + ((offset + i * beat_size) % boundary);
        req.HWDATA = 32'(200 + i);

        case (burst_cfg.HBURST)
            WRAP4  : req.pattern_id = PATTERN_WRAP4;
            WRAP8  : req.pattern_id = PATTERN_WRAP8;
            WRAP16 : req.pattern_id = PATTERN_WRAP16;
        endcase
            `uvm_info("DRIVER",
                    $sformatf("HADDR=0x%08h HSIZE=%0d HBURST=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h HREADY=%0b HBUSREQ=%0b HGRANT=%0b",
                        dut_vif.driver_cb.HADDR,    dut_vif.driver_cb.HSIZE,
                        dut_vif.driver_cb.HBURST,   dut_vif.driver_cb.HTRANS,
                        dut_vif.driver_cb.HWRITE,   dut_vif.driver_cb.HWDATA,
                        dut_vif.driver_cb.HREADY,   dut_vif.driver_cb.HBUSREQ[0],
                        dut_vif.driver_cb.HGRANT[0]),
                    UVM_MEDIUM
                    );
        finish_item(req);
    end

    // -------------------------------------------------
    // Step-4: WRAP READ burst
    // -------------------------------------------------
    for (int i = 0; i < burst_len; i++) begin
        req = ahb_seq_item::type_id::create($sformatf("wrap_rd_%0d", i));

        start_item(req);

        req.HBURST = burst_cfg.HBURST;
        req.HSIZE  = burst_cfg.HSIZE;
        req.HWRITE = 1'b0;
        req.HADDR  = aligned_base + ((offset + i * beat_size) % boundary);

        case (burst_cfg.HBURST)
            WRAP4  : req.pattern_id = PATTERN_WRAP4;
            WRAP8  : req.pattern_id = PATTERN_WRAP8;
            WRAP16 : req.pattern_id = PATTERN_WRAP16;
        endcase
            `uvm_info("DRIVER",
                    $sformatf("HADDR=0x%08h HSIZE=%0d HBURST=%0d HTRANS=%0b HWRITE=%0b HWDATA=0x%08h HREADY=%0b HBUSREQ=%0b HGRANT=%0b",
                        dut_vif.driver_cb.HADDR,    dut_vif.driver_cb.HSIZE,
                        dut_vif.driver_cb.HBURST,   dut_vif.driver_cb.HTRANS,
                        dut_vif.driver_cb.HWRITE,   dut_vif.driver_cb.HWDATA,
                        dut_vif.driver_cb.HREADY,   dut_vif.driver_cb.HBUSREQ[0],
                        dut_vif.driver_cb.HGRANT[0]),
                    UVM_MEDIUM
                    );
        finish_item(req);
    end
endtask : body