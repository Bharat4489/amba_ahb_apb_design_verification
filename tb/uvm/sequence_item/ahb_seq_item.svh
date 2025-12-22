//UNCHECKED

class ahb_seq_item extends ahb_base_seq_item;       //adding constraints on seq items
    `uvm_object_utils(ahb_seq_item)

    function new(string name = "ahb_seq_item");
        super.new(name);
    endfunction //new()

    constraint HTRANS_c {HTRANS == 'b10;}        //currently only NON_SEQ
    constraint HSEL_c   {HSEL == 'b0;}           //curently have only one slave
    constraint HADDR_c { HADDR dist { [32'h0000_0000 : 32'h0000_FFFF] := 60,
                                      [32'h0001_0000 : 32'hFFFF_FFFF] := 40 }; }


endclass //ahb_seq_item extends ahb_base_seq_item