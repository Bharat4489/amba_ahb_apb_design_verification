// Registers

module ahb_split_slave #(parameter int SPLIT_DELAY = 5) (
    ahb_if.slave_mp split_if
);

    logic split_pending;
    int  split_cnt;
    int  blocked_master;

    // Address phase: capture SPLIT decision & timing
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            split_pending  <= 1'b0;
            split_cnt      <= 0;
            blocked_master <= '0;
        end
        else begin
            // Address phase: decide to SPLIT
            if (sel && !split_pending) begin
            split_pending  <= 1'b1;
            split_cnt      <= 0;
            blocked_master <= HMASTER;
            end
            else if (split_pending) begin
            split_cnt <= split_cnt + 1;
            end
        end
    end

    // SPLIT response-drive bus response
    always_comb begin
        HREADY = 1'b1;
        HRESP  = OKAY;
        HSPLIT = '0;

        if (split_pending) begin
            HREADY = 1'b0;
            HRESP  = SPLIT;
        end
    end


    // Re-enable master after delay
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HSPLIT <= '0;
        end
        else if (split_pending && split_cnt == SPLIT_DELAY) begin
            HSPLIT[blocked_master] <= 1'b1;
        end
        else begin
            HSPLIT <= '0;
        end
    end


endmodule
