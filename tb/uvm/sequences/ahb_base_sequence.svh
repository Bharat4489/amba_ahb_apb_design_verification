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
    req = ahb_seq_item::type_id::create("req", this);

    start_item(req);

    if (!req.randomize())
      `uvm_fatal("SEQUENCER:RAND_FAIL", "Randomization failed");

    finish_item(req);

    `uvm_info("SEQUENCER:", req.sprint(), UVM_LOW)
  end
endtask
