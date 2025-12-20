class ahb_seq_item extends ahb_base_seq_item;       //adding constraints on seq items
    `uvm_object_utils(ahb_seq_item)

    function new(string name = "ahb_seq_item");
        super.new(name);
    endfunction //new()

    constraint HTRANS_c {HTRANS == 'b10;}        //currently only NON_SEQ

endclass //ahb_seq_item extends ahb_base_seq_item