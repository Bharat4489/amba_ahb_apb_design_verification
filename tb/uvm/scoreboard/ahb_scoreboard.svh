class ahb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ahb_scoreboard)

    uvm_analysis_imp #(ahb_seq_item, ahb_scoreboard) analysis_imp;

    //reference model memory
    logic [DATA_WIDTH-1:0] ref_mem [bit[ADDR_WIDTH-1:0]];

    extern function new(string name = "ahb_scoreboard", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void write(ahb_seq_item t); // callback for transactions

endclass : ahb_scoreboard


function ahb_scoreboard::new(string name = "ahb_scoreboard", uvm_component parent);
    super.new(name, parent);
endfunction: new

  // ------------------------------------------------------------------
  // build_phase
  // ------------------------------------------------------------------
function void ahb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp = new("analysis_imp", this);
endfunction : build_phase

  // ------------------------------------------------------------------
  // Called automatically when monitor writes a transaction
  // ------------------------------------------------------------------
function void ahb_scoreboard::write(ahb_seq_item txn);
    if (txn.HWRITE) begin
        ref_mem[txn.HADDR]=txn.HWDATA;

    end else begin
        if (!ref_mem.exists[txn.HADDR])         //to check assoc array cell value we use exists
            `uvm_error("AHB_SCOREBOARD:ERROR_1", $sformatf("address read is not present already. read_addr=%0h",txn.HADDR))  //uvm_error does NOT take verbosity
         
        else if(ref_mem[txn.HADDR]!== txn.HRDATA) 
            `uvm_error("AHB_SCOREBOARD:ERROR_2", $sformatf("DATA_MISMATCH:exp_data[%0h]=%0h, real_data[%0h]=%0h",txn.HADDR, ref_mem[txn.HADDR],txn.HADDR, txn.HRDATA));        

    end 
    `uvm_info("AHB_SCOREBOARD", $sformatf("Received item: %p", txn), UVM_MEDIUM)
endfunction
