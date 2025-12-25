//top test module which call run_test


module tb_top ();
    import uvm_pkg::*;
    import ahb_pkg::*;
    ahb_if ahb_if1();       //instantiate real interface-use parantheses'()' w/o it, we will get compilation error as compiler look for port list 
    
    //RTL:>>>instantiated and connected
    ahb_top u_ahb_top(.real_if(ahb_if1));


    // Clock generator: 100 MHz example (10 ns period)
    initial begin
      ahb_if1.HCLK = 0;
      forever #5 ahb_if1.HCLK = ~ahb_if1.HCLK;
    end

      // Proper reset sequencing on clock edges
      initial begin
        ahb_if1.HRESETn = 0;
        repeat (2) @(posedge ahb_if1.HCLK);
        ahb_if1.HRESETn = 1; // release it on a clock edge to ensure stable initialization and avoid metastability
        $display("[%0t] HRESETn deasserted", $time);
      end

      initial begin
        // Place the interface into the UVM configuration database
        uvm_config_db#(virtual ahb_if)::set(null, "*", "ahb_vif", ahb_if1);
        uvm_config_db#(virtual ahb_if.master_mp)::set(null, "*", "ahb_vif", ahb_if1.master_mp);
        uvm_config_db#(virtual ahb_if.monitor_mp)::set(null, "*", "ahb_vif", ahb_if1.monitor_mp);
        uvm_config_db#(virtual ahb_if.slave_mp)::set(null, "*", "ahb_vif", ahb_if1.slave_mp);
        // Start the test
        run_test("my_test");      //It is a UVM library task defined in uvm_pkg- IT FINDS my_test via `uvm_component_utils(my_test)
      end

      initial begin
        $display("### TB_TOP STARTED ###");
        $shm_open("ahb_waves"); //how this helped in getting waves
        $shm_probe("AS", tb_top);  //"AS" = record EVERYTHING under this scope
      end


      initial begin
        #9000ns;  // Wait for 100 ns of simulation time
        $display("[%0t] Simulation timeout reached. Finishing...", $time);
        $finish; // Ends simulation cleanly
      end

endmodule
