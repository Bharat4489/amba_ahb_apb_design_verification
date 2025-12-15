//top test module which call run_test


module tb_top ();
    import uvm_pkg::*;
    import ahb_pkg::*;
    ahb_if ahb_if1();       //instantiate real interface-use parantheses'()' w/o it, we will get compilation error as compiler look for port list 

    initial begin
        ahb_if1.HCLK = 'b0;
        ahb_if1.HRESETn = 'b0;
        #20 ahb_if1.HRESETn = 'b1;         // release it on a clock edge to ensure stable initialization and avoid metastability

        forever #5 ahb_if1.HCLK = ~ ahb_if1.HCLK;
    end

      initial begin
        // Place the interface into the UVM configuration database
        uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif", ahb_if1);
        // Start the test
        run_test("my_test");
      end
endmodule