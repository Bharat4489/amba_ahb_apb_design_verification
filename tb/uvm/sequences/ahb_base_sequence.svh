class ahb_base_sequence  extends uvm_sequence#(ahb_seq_item);
    `uvm_object_utils(ahb_base_sequence)

    ahb_seq_item req;

    function new(string name = "ahb_base_sequence");
        super.new(name);
    endfunction
    
    extern task body();
endclass : ahb_base_sequence

task ahb_base_sequence::body();
  repeat (5) 
  begin
    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    if (!req.randomize())
      `uvm_fatal("SEQUENCE:RAND_FAIL", "Randomization failed");
    `uvm_info("SEQUENCE:", req.sprint(), UVM_LOW)

    finish_item(req);
  end
endtask
