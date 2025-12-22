import ahb_params_pkg::*;

module ahb_sram_slave (
    ahb_if.slave_mp sram_if
);

    // ------------------------------------------------------------
    // 8 KB SRAM
    // DATA_WIDTH = 32 bits (4 bytes per word)
    // ------------------------------------------------------------
    logic [DATA_WIDTH-1:0] sram_memory [0:2047];
    logic [3:0] byte_en;

    // Word-aligned address (internal SRAM index)
    int unsigned word_addr;

    // ------------------------------------------------------------
    // Always-ready, fast SRAM slave
    // ------------------------------------------------------------
    assign sram_if.HREADY = 1'b1;     // No wait states
    assign sram_if.HRESP  = 2'b00;    // OKAY response always

    // ------------------------------------------------------------
    // Byte enable decode (combinational)
    // Decodes HSIZE + HADDR[1:0]
    // ------------------------------------------------------------
    always_comb begin
        byte_en = 4'b0000;

        case (sram_if.HSIZE)
            3'b000:  byte_en = 4'b0001 << sram_if.HADDR[1:0];
            3'b001:  byte_en = sram_if.HADDR[1] ? 4'b1100 : 4'b0011;
            3'b010:  byte_en = 4'b1111;
            default: byte_en = 4'b0000;
        endcase
    end

    // ------------------------------------------------------------
    // SRAM read/write behavior
    // ------------------------------------------------------------
    always_ff @(posedge sram_if.HCLK or negedge sram_if.HRESETn) begin
        if (!sram_if.HRESETn) begin
            sram_if.HRDATA <= '0;
        end
        else if (sram_if.HSEL && (sram_if.HTRANS == 2'b10 || sram_if.HTRANS == 2'b11)) begin

            word_addr = sram_if.HADDR[12:2];    // Convert byte address to word index

            if (sram_if.HWRITE) begin
                // -----------------------------
                // WRITE with byte masking
                // -----------------------------
                if (byte_en[0]) sram_memory[word_addr][7:0]   <= sram_if.HWDATA[7:0];
                if (byte_en[1]) sram_memory[word_addr][15:8]  <= sram_if.HWDATA[15:8];
                if (byte_en[2]) sram_memory[word_addr][23:16] <= sram_if.HWDATA[23:16];
                if (byte_en[3]) sram_memory[word_addr][31:24] <= sram_if.HWDATA[31:24];
            end
            else begin
                // -----------------------------
                // READ
                // -----------------------------
                sram_if.HRDATA <= sram_memory[word_addr];
            end
        end
    end

endmodule
