// -------------------------------------------------
// Global AHB Parameters
// -------------------------------------------------
package ahb_params_pkg;

    parameter int DATA_WIDTH     = 32;
    parameter int ADDR_WIDTH     = 32;
    parameter int NO_OF_MASTERS  = 2;
    parameter int NO_OF_SLAVES   = 3;
    // HTRANS enconding
    parameter IDLE=2'b00;
    parameter BUSY=2'b01;
    parameter NONSEQ=2'b10;
    parameter SEQ=2'b11; 
    // HSIZE encoding
    parameter BYTE=3'b000;
    parameter HALF_WORD=3'b001
    parameter WORD=3'b010;
    // HBURST encodings
    parameter SINGLE  = 3'b000; 
    parameter INCR    = 3'b001; 
    parameter WRAP4   = 3'b010;  
    parameter INCR4   = 3'b011;  
    parameter WRAP8   = 3'b100; 
    parameter INCR8   = 3'b101;  
    parameter WRAP16  = 3'b110;  
    parameter INCR16  = 3'b111;  

    typedef enum int {
        PATTERN_SINGLE,
        PATTERN_INCR;
        PATTERN_INCR4,
        PATTERN_INCR8,
        PATTERN_INCR16,
        PATTERN_WRAP4,
        PATTERN_UNDEFINED
    } pattern_id_t;

endpackage : ahb_params_pkg
