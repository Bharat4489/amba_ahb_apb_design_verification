import ahb_params_pkg::*;

module ahb_default_slave (
    ahb_if.slave_mp real_if
);

    // ------------------------------------------------------------
    // Default AHB Slave
    //  - Responds to unmapped addresses
    //  - Always returns ERROR
    //  - Never inserts wait states
    //  - No storage, no read/write behavior
    // ------------------------------------------------------------

    always_ff @(posedge real_if.HCLK or negedge real_if.HRESETn) begin
        if (!real_if.HRESETn) begin
            real_if.HREADY <= 1'b1;
            real_if.HRESP  <= 2'b00;   // OKAY during reset (safe default)
            real_if.HRDATA <= '0;
        end
        else begin
            // Default behavior: ready, no wait states
            real_if.HREADY <= 1'b1;

            // Respond only when this slave is selected
            if (real_if.HSEL && (real_if.HTRANS != 2'b00)) begin
                real_if.HRESP <= 2'b01; // ERROR response
            end
            else begin
                real_if.HRESP <= 2'b00; // OKAY when not selected
            end

            // HRDATA is don't-care for default slave
            real_if.HRDATA <= '0;
        end
    end

endmodule
