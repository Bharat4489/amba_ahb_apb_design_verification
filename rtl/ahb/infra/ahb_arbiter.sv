import ahb_params_pkg::*;

module ahb_arbiter (
    ahb_if.arbiter_mp arbiter_if
);

  // -------------------------------------------------
  // State
  // -------------------------------------------------
  int curr_master;      // registered granted master
  int next_master;      // combinational next master

  logic [NO_OF_MASTERS-1:0] split_mask; // 1 = master split-blocked

  // -------------------------------------------------
  // Combinational arbitration logic
  // -------------------------------------------------
  always_comb begin
    next_master = curr_master;

    // Arbitration allowed only when bus is ready
    if (arbiter_if.HREADY && !arbiter_if.HLOCK[curr_master]) begin
      // Round-robin search (skip current master)
      for (int i = 1; i <= NO_OF_MASTERS; i++) begin
        int idx;
        idx = (curr_master + i) % NO_OF_MASTERS;

        if (arbiter_if.HBUSREQ[idx] && !split_mask[idx]) begin
          next_master = idx;   // BLOCKING assignment (important)
          break;
        end
      end
    end
  end

  // -------------------------------------------------
  // Sequential state update
  // -------------------------------------------------
  always_ff @(posedge arbiter_if.HCLK or negedge arbiter_if.HRESETn) begin
    if (!arbiter_if.HRESETn) begin
      curr_master <= 0;
      split_mask  <= '0;
      arbiter_if.HMASTER <= CPU;  //by default master_id has the bus
    end
    else begin
      curr_master <= next_master;

      // setting HMASTER
      arbiter_if.HMASTER  <= (curr_master==0)?CPU:DMA;       //HMASTER is updated 2 cycles after HBUSREQ if HREADY=1

      if (arbiter_if.HREADY) begin
        // If the granted master is presenting the address phase with HLOCK=1,
        // this transfer belongs to a locked sequence.
        if (arbiter_if.HLOCK[curr_master]) begin
          arbiter_if.HMASTLOCK <= 1'b1;
        end
        else begin
          // HLOCK low at the start of a new address phase => end of locked sequence
          // (i.e., next transfer is not locked)
          arbiter_if.HMASTLOCK <= 1'b0;
        end
      end


      // Clear split blocks when HSPLIT asserted
      split_mask <= split_mask & ~arbiter_if.HSPLIT;

      // Block current master on SPLIT response
      if (arbiter_if.HREADY && arbiter_if.HRESP == SPLIT)
        split_mask[curr_master] <= 1'b1;
    end
  end

  // -------------------------------------------------
  // Grant generation (from registered owner)
  // -------------------------------------------------
  always_comb begin
    arbiter_if.HGRANT = '0;
    arbiter_if.HGRANT[curr_master] = 1'b1;
  end

endmodule
