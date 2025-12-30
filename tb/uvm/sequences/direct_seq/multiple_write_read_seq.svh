class multiple_write_read_seq extends ahb_base_sequence;
    `uvm_object_utils(multiple_write_read_seq)

    ahb_seq_item req;

    extern function new(string name="multiple_write_read_seq");
    extern task body();

endclass : multiple_write_read_seq

function multiple_write_read_seq::new(string name = "multiple_write_read_seq");
    super.new(name);
endfunction : new

task multiple_write_read_seq::body();
    string msg;
    $sformat(msg,"starting consecutive writes");
    set_pattern_name(msg);
    // writing in consecutive addresses-keeping address in SRAM memory range
    for(int i=0; i<9; i++)
        begin
            req = ahb_seq_item::type_id::create("req");
            start_item(req);
            req.HPROT  = 4'b0001;
            req.HADDR   = i*4;      //word aligned
            req.HTRANS  = NONSEQ;
            req.HSIZE   = WORD;
            req.HWDATA  = 32'(200*i);
            req.HWRITE  = 1'b1;
            req.HBURST  = INCR;
            req.HLOCK   = 0;
            finish_item(req);
        end

    $sformat(msg,"starting consecutive reads");
    set_pattern_name(msg);
    // reading from above written consecutive addresse
    for(int i=0; i<9; i++)
        begin
            req = ahb_seq_item::type_id::create("req");
            start_item(req);
            req.HPROT  = 4'b0001;
            req.HADDR   = i*4;      //word aligned
            req.HTRANS  = NONSEQ;
            req.HSIZE   = WORD;
            req.HWRITE  = 1'b0;
            req.HBURST  = INCR;
            req.HLOCK   = 0;
            finish_item(req);
        end

endtask : body
