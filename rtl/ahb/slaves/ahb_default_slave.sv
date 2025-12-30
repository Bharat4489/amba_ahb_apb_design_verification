import ahb_params_pkg::*;

module ahb_default_slave (
    ahb_if.slave_mp default_if,     //connected to (.default_if(ahb_if.slave_mp));
    output logic [DATA_WIDTH-1:0]       hrdata_default,
    output logic                        hready_default,           //transfer done / wait-state control
    output hresp_t                      hresp_default,      //response (OKAY, ERROR, RETRY, SPLIT)
    output logic [NO_OF_MASTERS-1:0]    hsplit_default
);
    // ------------------------------------------------------------
    // Default AHB Slave
    //  - Responds to unmapped addresses
    //  - Always returns ERROR
    //  - Never inserts wait states
    //  - No storage, no read/write behavior
    // ------------------------------------------------------------

    // ------------------------------------------------------------
    // DEFAULT-SLAVE : SPLIT feature unsupported
    // ------------------------------------------------------------
    assign hsplit_default[NO_OF_MASTERS-1:0] = 'b0;     // No wait states


    always_ff @(posedge default_if.HCLK or negedge default_if.HRESETn) begin
        if (!default_if.HRESETn) begin
            hready_default <= 1'b1;
            hresp_default  <= OKAY;   // OKAY during reset (safe default)
            hrdata_default <= '0;
        end
        else begin
            // Default behavior: ready, no wait states
            hready_default <= 1'b1;

            // Respond only when this slave is selected
            if (default_if.HSEL_DEFAULT && (default_if.HTRANS != IDLE)) begin
                hresp_default <= ERROR; // ERROR response
            end
            else begin
                hresp_default <= OKAY; // OKAY when not selected
            end

            // HRDATA is don't-care for default slave
            hrdata_default <= '0;
        end
    end

endmodule
