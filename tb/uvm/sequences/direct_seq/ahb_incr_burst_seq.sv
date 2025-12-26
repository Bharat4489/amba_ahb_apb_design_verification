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
    int offset = 32'h100;
    logic [2:0] hsize_local;
    int beat_size;

    hsize_local = WORD;     //UPDATE HSIZE here
    case (hsize_local)
        BYTE      : beat_size = 1;
        HALF_WORD : beat_size = 2;
        WORD      : beat_size = 4;
        default   : beat_size = 4;
    endcase

    for ( int hburst= 4;hburst<17;hburst=hburst*2 ) begin      //HBURST=INCR4, INCR8, INCR16
        offset = offset+32'h1000;
        // -------------------------
        // INCR4/8/16 burst WRITE
        // -------------------------
        for (int i = 0; i<hburst; i++) begin
            req = ahb_seq_item::type_id::create($sformatf("wr_req_%0d_%0d",i, hburst));
            start_item(req);
            req.HADDR  = offset + i*beat_size;
            req.HSIZE  = hsize_local;
            req.HWRITE = 1'b1;
            req.HWDATA = 32'(200*i);
            case (hburst)
                4: begin req.pattern_id = PATTERN_INCR4;              req.HBURST = INCR4;     end
                8: begin req.pattern_id = PATTERN_INCR8;              req.HBURST = INCR8;     end
                16:begin req.pattern_id = PATTERN_INCR16;             req.HBURST = INCR16;    end
                default: begin req.pattern_id = PATTERN_UNDEFINED;    req.HBURST = INCR16;    end
            endcase     
            finish_item(req);
        end

        // -------------------------
        // INCR4/8/16 burst READ
        // -------------------------
        for (int i = 0; i<hburst; i++) begin
            req = ahb_seq_item::type_id::create($sformatf("rd_req_%0d_%0d",i, hburst));
            start_item(req);
            req.HADDR  = offset + i*beat_size;
            req.HSIZE  = hsize_local;
            req.HWRITE = 1'b0;
            case (hburst)
                4: begin req.pattern_id = PATTERN_INCR4;              req.HBURST = INCR4;     end
                8: begin req.pattern_id = PATTERN_INCR8;              req.HBURST = INCR8;     end
                16:begin req.pattern_id = PATTERN_INCR16;             req.HBURST = INCR16;    end
                default: begin req.pattern_id = PATTERN_UNDEFINED;    req.HBURST = INCR16;    end
            endcase 
            finish_item(req);    
        end 
    end
endtask
