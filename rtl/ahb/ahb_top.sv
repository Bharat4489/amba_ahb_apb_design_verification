module ahb_top (
    ahb_if real_if
);

    // Local signals from slaves
    logic [DATA_WIDTH-1:0] hrdata_sram;
    logic [DATA_WIDTH-1:0] hrdata_default;
    logic [DATA_WIDTH-1:0] hrdata_split;
    logic                  hready_sram;
    logic                  hready_default;
    logic                  hready_split;
    logic [1:0]            hresp_sram;
    logic [1:0]            hresp_default;
    logic [1:0]            hresp_split;
    logic [NO_OF_MASTERS-1:0] hsplit_sram;
    logic [NO_OF_MASTERS-1:0] hsplit_default;
    logic [NO_OF_MASTERS-1:0] hsplit_split;



    //arbiter
    ahb_arbiter u_arbiter (
        .arbiter_if(real_if.arbiter_mp)
        );

    // Decoder
    ahb_decoder u_decoder (
        .decoder_if(real_if.decoder_mp)
    );

    // Default slave
    ahb_default_slave u_default_slave (
        .default_if     (real_if.slave_mp),
        .hrdata_default   (hrdata_default),
        .hready_default   (hready_default),
        .hresp_default    (hresp_default),
        .hsplit_default   (hsplit_default)
    );

    // SRAM slave
    ahb_sram_slave u_sram_slave (
        .sram_if     (real_if.slave_mp),
        .hrdata_sram   (hrdata_sram),
        .hready_sram   (hready_sram),
        .hresp_sram    (hresp_sram),
        .hsplit_sram   (hsplit_sram)
    );

    ahb_split_slave u_split_slave(
        .split_if   (real_if.slave_mp),
        .hrdata_split (hrdata_split),
        .hready_split(hready_split),
        .hresp_split (hresp_split),
        .hsplit_split(hsplit_split)

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
            real_if.HSPLIT = hsplit_sram;
        end
        else if (real_if.HSEL_DEFAULT) begin
            real_if.HRDATA = hrdata_default;
            real_if.HREADY = hready_default;
            real_if.HRESP  = hresp_default;
            real_if.HSPLIT = hsplit_default;
        end
    end

endmodule
