// -------------------------------------------------
// Global AHB Parameters
// -------------------------------------------------
package ahb_params_pkg;

    parameter int DATA_WIDTH     = 32;
    parameter int ADDR_WIDTH     = 32;
    parameter int NO_OF_MASTERS  = 2;
    parameter int NO_OF_SLAVES   = 3;
    // // HTRANS enconding
    // parameter IDLE=2'b00;
    // parameter BUSY=2'b01;
    // parameter NONSEQ=2'b10;
    // parameter SEQ=2'b11;
    // // HSIZE encoding
    // parameter BYTE=3'b000;
    // parameter HALF_WORD=3'b001;
    // parameter WORD=3'b010;
    // // HBURST encodings
    // parameter SINGLE  = 3'b000;
    // parameter INCR    = 3'b001;
    // parameter WRAP4   = 3'b010;
    // parameter INCR4   = 3'b011;
    // parameter WRAP8   = 3'b100;
    // parameter INCR8   = 3'b101;
    // parameter WRAP16  = 3'b110;
    // parameter INCR16  = 3'b111;

    typedef enum int {
        PATTERN_SINGLE,
        PATTERN_INCR,
        PATTERN_INCR4,
        PATTERN_INCR8,
        PATTERN_INCR16,
        PATTERN_WRAP4,
        PATTERN_WRAP8,
        PATTERN_WRAP16,
        PATTERN_UNDEFINED
    } pattern_id_t;

    typedef enum logic [1:0] {
        IDLE    = 2'b00, // No transfer
        BUSY    = 2'b01, // Busy, pipeline stall
        NONSEQ  = 2'b10, // Non-sequential transfer
        SEQ     = 2'b11  // Sequential transfer
    } htrans_t;

    typedef enum logic [2:0] {
        SINGLE = 3'b000, // Single transfer
        INCR   = 3'b001, // Incrementing burst (unspecified length)
        WRAP4  = 3'b010, // 4-beat wrapping burst
        INCR4  = 3'b011, // 4-beat incrementing burst
        WRAP8  = 3'b100, // 8-beat wrapping burst
        INCR8  = 3'b101, // 8-beat incrementing burst
        WRAP16 = 3'b110, // 16-beat wrapping burst
        INCR16 = 3'b111  // 16-beat incrementing burst
    } hburst_t;

    typedef enum logic [2:0] {
        BYTE      = 3'b000, // 8-bit transfer
        HALF_WORD  = 3'b001, // 16-bit transfer
        WORD      = 3'b010  // 32-bit transfer
    } hsize_t;

    typedef enum logic [1:0] {
        OKAY   = 2'b00, // Normal transfer completed
        ERROR  = 2'b01, // Error response
        RETRY  = 2'b10, // Retry requested
        SPLIT  = 2'b11  // Split response
    } hresp_t;

    typedef enum logic [NO_OF_MASTERS-1:0]{
        CPU_MASTER  =   2'b00,
        DMA_MASTER  =   2'b01
    } master_id_t;

    typedef enum logic [NO_OF_SLAVES-1:0]{
        DEFAULT_SLAVE,
        SRAM_SLAVE,
        SPLIT_SLAVE
    } slave_id_t;

    typedef enum logic [$clog2(NO_OF_MASTERS)-1:0]{
        CPU  =   0,
        DMA  =   1
    } hmaster_t;

endpackage : ahb_params_pkg
