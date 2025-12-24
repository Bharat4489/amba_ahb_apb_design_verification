import ahb_params_pkg::*;

module ahb_decoder (
    ahb_if.decoder_mp decoder_if
);

    always_comb begin
        // Default: no slave selected
        decoder_if.HSEL_SRAM    = 1'b0;
        decoder_if.HSEL_DEFAULT = 1'b0;

        // Only decode during valid transfers
        if (decoder_if.HRESETn &&
            (decoder_if.HTRANS == NONSEQ || decoder_if.HTRANS == SEQ)) begin

            if (decoder_if.HADDR >= 32'h0000_0000 &&
                decoder_if.HADDR <= 32'h0000_FFFF)
                decoder_if.HSEL_SRAM = 1'b1;
            else
                decoder_if.HSEL_DEFAULT = 1'b1;
        end
    end
endmodule
