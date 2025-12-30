// Registers

module ahb_split_slave #(parameter int SPLIT_DELAY = 5) (
    ahb_if.slave_mp split_if,
    output logic [DATA_WIDTH-1:0]   hrdata_split,
    output logic                    hready_split,     //transfer done / wait-state control
    output hresp_t                  hresp_split,      //response (OKAY, ERROR, RETRY, SPLIT)
    output logic [NO_OF_MASTERS-1:0]      hsplit_split
);

    logic split_pending;
    int  split_cnt;
    int  blocked_master;

    // Address phase: capture SPLIT decision & timing
    always_ff @(posedge split_if.HCLK or negedge split_if.HRESETn) begin
        if (!split_if.HRESETn) begin
            split_pending  <= 1'b0;
            split_cnt      <= 0;
            blocked_master <= '0;
        end
        else begin
            // Address phase: decide to SPLIT
            if (split_if.HSEL_SPLIT && !split_pending) begin
            split_pending  <= 1'b1;
            split_cnt      <= 0;
            blocked_master <= split_if.HMASTER;
            end
            else if (split_pending) begin
            split_cnt <= split_cnt + 1;
            end
        end
    end

    // SPLIT response-drive bus response
    always_comb begin
        hready_split = 1'b1;
        hresp_split  = OKAY;
        if (split_pending) begin
            hready_split = 1'b0;
            hresp_split  = SPLIT;
        end
    end


    // Re-enable master after delay
    always_ff @(posedge split_if.HCLK or negedge split_if.HRESETn) begin
        if (!split_if.HRESETn) begin
            hsplit_split <= '0;
        end
        else if (split_pending && split_cnt == SPLIT_DELAY) begin
            hsplit_split[blocked_master] <= 1'b1;
        end
        else begin
            hsplit_split <= '0;
        end
    end


endmodule
