module ahb_top (
    ahb_if real_if
);

    // Local signals from slaves
    logic [DATA_WIDTH-1:0] hrdata_sram;
    logic [DATA_WIDTH-1:0] hrdata_default;
    logic                  hready_sram;
    logic                  hready_default;
    logic [1:0]            hresp_sram;
    logic [1:0]            hresp_default;

    // Decoder
    ahb_decoder u_decoder (
        .decoder_if(real_if.decoder_mp)
    );

    // Default slave
    ahb_default_slave u_default_slave (
        .slave_if     (real_if.slave_mp),
        .hrdata_out   (hrdata_default),
        .hready_out   (hready_default),
        .hresp_out    (hresp_default)
    );

    // SRAM slave
    ahb_sram_slave u_sram_slave (
        .slave_if     (real_if.slave_mp),
        .hrdata_out   (hrdata_sram),
        .hready_out   (hready_sram),
        .hresp_out    (hresp_sram)
    );

    // -----------------------------
    // RESPONSE MUX (single driver)
    // -----------------------------
    always_comb begin
        real_if.HRDATA = '0;
        real_if.HREADY = 1'b1;
        real_if.HRESP  = 2'b00;

        if (real_if.HSEL_SRAM) begin
            real_if.HRDATA = hrdata_sram;
            real_if.HREADY = hready_sram;
            real_if.HRESP  = hresp_sram;
        end
        else if (real_if.HSEL_DEFAULT) begin
            real_if.HRDATA = hrdata_default;
            real_if.HREADY = hready_default;
            real_if.HRESP  = hresp_default;
        end
    end

endmodule
