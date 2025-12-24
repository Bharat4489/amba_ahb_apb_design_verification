import ahb_params_pkg::*;

module ahb_default_slave (
    ahb_if.slave_mp default_if,     //connected to (.default_if(ahb_if.slave_mp));
    output logic [DATA_WIDTH-1:0] hrdata_default,
    output logic hready_default,           //transfer done / wait-state control
    output logic [1:0] hresp_default      //response (OKAY, ERROR, RETRY, SPLIT)
);
    // ------------------------------------------------------------
    // Default AHB Slave
    //  - Responds to unmapped addresses
    //  - Always returns ERROR
    //  - Never inserts wait states
    //  - No storage, no read/write behavior
    // ------------------------------------------------------------

    always_ff @(posedge default_if.HCLK or negedge default_if.HRESETn) begin
        if (!default_if.HRESETn) begin
            hready_default <= 1'b1;
            hresp_default  <= 2'b00;   // OKAY during reset (safe default)
            hrdata_default <= '0;
        end
        else begin
            // Default behavior: ready, no wait states
            hready_default <= 1'b1;

            // Respond only when this slave is selected
            if (default_if.HSEL_DEFAULT && (default_if.HTRANS != IDLE)) begin
                hresp_default <= 2'b01; // ERROR response
            end
            else begin
                hresp_default <= 2'b00; // OKAY when not selected
            end

            // HRDATA is don't-care for default slave
            hrdata_default <= '0;
        end
    end

endmodule
