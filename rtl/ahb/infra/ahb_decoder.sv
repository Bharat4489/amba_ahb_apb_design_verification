import ahb_params_pkg::*;

module ahb_decoder (
    ahb_if.decoder_mp decoder_if
);

    always_comb begin
        // Default: no slave selected
        decoder_if.HSEL_SRAM    = 1'b0;
        decoder_if.HSEL_DEFAULT = 1'b0;
        decoder_if.HSEL_SPLIT   = 1'b0;

        // Only decode during valid transfers
        if (decoder_if.HRESETn &&
            (decoder_if.HTRANS == NONSEQ || decoder_if.HTRANS == SEQ)) begin
              // Use HADDR[31:10] because 1KB = 2^10 bytes
              unique case (decoder_if.HADDR[31:10])
                22'h000001: begin
                                decoder_if.HSEL_SRAM    = 1'b1;     // 0x0000_0400 .. 0x0000_07FF
                                decoder_if.slave_id     = SRAM_SLAVE;
                            end
                22'h000002: begin
                                decoder_if.HSEL_SPLIT   =  1'b1;    // 0x0000_0800 .. 0x0000_0BFF
                                decoder_if.slave_id     =  SPLIT_SLAVE;
                            end
                default:    begin
                                decoder_if.HSEL_DEFAULT = 1'b1;
                                decoder_if.slave_id     = DEFAULT_SLAVE;
                            end
              endcase
        end
    end
endmodule
