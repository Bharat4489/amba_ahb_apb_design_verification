class ahb_basic_burst_seq extends ahb_base_sequence;
    `uvm_object_utils(ahb_basic_burst_seq)

    extern function new(string name = "ahb_basic_burst_seq");
    extern task body();

endclass //ahb_basic_burst_seq

    // -------------------------
    // NEW
function ahb_basic_burst_seq::new(string name = "ahb_basic_burst_seq")
    super.new(name);
endfunction

    // -------------------------
    // BODY
task automatic ahb_basic_burst_seq::body();
    ahb_seq_item req;   //seq_item handle
    int offset = 32'h100;

    // -------------------------
    // INCR burst WRITE
    // -------------------------
    for (int i = 0; i < 10; i++) begin
      req = ahb_seq_item::type_id::create($sformatf("wr_req_%0d", i));

      start_item(req);
      req.pattern_id = PATTERN_INCR;
      req.HADDR  = offset + i*4;
      req.HBURST = INCR;
      req.HSIZE  = WORD;
      req.HWRITE = 1'b1;
      req.HWDATA = 32'(200*i);
      finish_item(req);
    end

    // -------------------------
    // INCR burst READ
    // -------------------------
    for (int i = 0; i < 10; i++) begin
      req = ahb_seq_item::type_id::create($sformatf("rd_req_%0d", i));

      start_item(req);
      req.pattern_id = PATTERN_INCR;
      req.HADDR  = offset + i*4;
      req.HBURST = INCR;
      req.HSIZE  = WORD;
      req.HWRITE = 1'b0;
      finish_item(req);
    end
endtask
