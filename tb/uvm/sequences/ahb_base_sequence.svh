
class ahb_base_sequence  extends uvm_sequence#(ahb_seq_item);
    `uvm_object_utils(ahb_base_sequence)

    virtual ahb_if if1;
    ahb_seq_item req;

    function new(string name = "ahb_base_sequence");
        super.new(name);
    endfunction
    
    extern virtual task body();
    // extern virtual task set_pattern_name(string msg);
endclass : ahb_base_sequence


task ahb_base_sequence::body();
  repeat (5) 
  begin
    req = ahb_seq_item::type_id::create("req");

    start_item(req);

    if (!req.randomize())
      `uvm_fatal("SEQUENCE:RAND_FAIL", "Randomization failed");
    //`uvm_info("SEQUENCE:", req.sprint(), UVM_MEDIUM)

    finish_item(req);
  end
endtask

// task ahb_base_sequence::set_pattern_name(string msg);
//     if (!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", if1)) begin
//       `uvm_fatal("ahb_base_sequence","Unable to get virtual if for SEQUENCE. Have you set it properly?")
//     end
//   if1.pattern_name = msg;
//   ->if1.pattern_update;
// endtask: set_pattern_name
