//top test module which call run_test

`include "uvm_macros.svh"

module tb_top ();
    import ahb_pkg::*;
    ahb_if ahbif();       //instantiate real interface-use parantheses'()' w/o it, we will get compilation error as compiler look for port list 

    initial begin
        ahbif.HCLK = 'b0;
        ahbif.HRESETn = 'b0;
        #20 ahbif.HRESETn = 'b1;         // release it on a clock edge to ensure stable initialization and avoid metastability

        forever #5 ahbif.HCLK = ~ ahbif.HCLK;
    end

    initial begin
        run_test("my_test");
    end
endmodule