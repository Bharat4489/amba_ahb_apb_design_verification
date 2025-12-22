import ahb_params_pkg::*;

class ahb_base_seq_item extends uvm_sequence_item;          //adding seq items
    `uvm_object_utils(ahb_base_seq_item)

    function new(string name = "ahb_base_seq_item");
        super.new(name);
    endfunction

    //transaction-level fields,(not signals) 
    rand logic                      HWRITE;
    rand logic [1:0]                HTRANS;
    rand logic [2:0]                HSIZE;
    rand logic [2:0]                HBURST;
    rand logic [DATA_WIDTH-1:0]     HWDATA;
    rand logic [ADDR_WIDTH-1:0]     HADDR;
    rand logic HREADY;
    rand logic [NO_OF_SLAVES-1:0]   HSEL;            // Decoder: slave select (one-hot) 
         logic [3:0]                HPROT;
         logic [NO_OF_MASTERS-1:0]  HBUSREQ;

    extern function void do_print(uvm_printer printer);     //how does do_print works

endclass : ahb_base_seq_item 

function void ahb_base_seq_item::do_print(uvm_printer printer);
    super.do_print(printer);

    printer.print_field("HWRITE", this.HWRITE, 1, UVM_DEC);
    printer.print_field("HTRANS", this.HTRANS, 2, UVM_BIN);
    printer.print_field("HADDR", this.HADDR, 32, UVM_HEX);
    printer.print_field("HSIZE", this.HSIZE, 3, UVM_DEC);
    printer.print_field("HBURST", this.HBURST, 3, UVM_DEC);
    printer.print_field("HWDATA", this.HWDATA, 32, UVM_HEX);
    printer.print_field("HREADY", this.HREADY, 1,  UVM_DEC);
    printer.print_field("HSEL", this.HSEL, 3,  UVM_BIN);
endfunction