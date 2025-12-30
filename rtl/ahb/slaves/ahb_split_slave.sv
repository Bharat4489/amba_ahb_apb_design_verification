// Registers

module ahb_split_slave (
    ahb_if.slave_mp split_if;
);
    logic split_pending;
    int  split_cnt;
    int  blocked_master;

    // Address phase: decide to split
    if (sel && !split_pending) begin
    split_pending  <= 1'b1;
    split_cnt      <= 0;
    blocked_master <= HMASTER;
    end

    // SPLIT response
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
        split_pending <= 0;
        split_cnt     <= 0;
    end else if (split_pending) begin
        split_cnt <= split_cnt + 1;

        if (split_cnt == SPLIT_DELAY) begin
        HSPLIT[blocked_master] <= 1'b1;
        split_pending <= 1'b0;
        end
    end
    end

endmodule
