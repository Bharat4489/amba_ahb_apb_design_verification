class ahb_seq_item extends ahb_base_seq_item;       //adding constraints on seq items
    `uvm_object_utils(ahb_seq_item)

    function new(string name = "ahb_seq_item");
        super.new(name);
    endfunction //new()

    constraint master_signal_c {
        HTRANS  inside {NONSEQ, SEQ};
        HSIZE   inside {BYTE, HALF_WORD, WORD};
        HADDR   inside {[32'h0000_0000 : 32'h0000_FFFF]};
        HBURST  inside {INCR, INCR4, INCR8, INCR16, WRAP4, WRAP8, WRAP16};
        (HSIZE == HALF_WORD) -> (HADDR[0]   == 1'b0);           // - HALF_WORD : 16-bit alignment
        (HSIZE == WORD     ) -> (HADDR[1:0] == 2'b00);          // - WORD      : 32-bit alignment
    }

    pattern_id_t pattern_id;

endclass //ahb_seq_item extends ahb_base_seq_item


