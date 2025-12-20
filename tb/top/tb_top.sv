//top test module which call run_test


module tb_top ();
    import uvm_pkg::*;
    import ahb_pkg::*;
    ahb_if ahb_if1();       //instantiate real interface-use parantheses'()' w/o it, we will get compilation error as compiler look for port list 

      initial begin
        ahb_if1.HCLK = 0;
        ahb_if1.HRESETn = 0;
        repeat (2) @(posedge ahb_if1.HCLK); // release it on a clock edge to ensure stable initialization and avoid metastability
        ahb_if1.HRESETn = 1;
      end

      initial begin
        // Place the interface into the UVM configuration database
        uvm_config_db#(virtual ahb_if.master_mp)::set(null, "*", "ahb_vif", ahb_if1.master_mp);
        uvm_config_db#(virtual ahb_if.slave_mp)::set(null, "*", "ahb_vif", ahb_if1.slave_mp);
        uvm_config_db#(virtual ahb_if.monitor_mp)::set(null, "*", "ahb_vif", ahb_if1.monitor_mp);
        // Start the test
        run_test("my_test");      //It is a UVM library task defined in uvm_pkg- IT FINDS my_test via `uvm_component_utils(my_test)
      end

      initial begin
        $display("### TB_TOP STARTED ###");
        $shm_open("ahb_waves"); //how this helped in getting waves
        $shm_probe("AS", tb_top);  //"AS" = record EVERYTHING under this scope
      end

endmodule