// -------------------------------------------------
// Global AHB Parameters
// -------------------------------------------------
package ahb_params_pkg;

    parameter int DATA_WIDTH     = 32;
    parameter int ADDR_WIDTH     = 32;
    parameter int NO_OF_MASTERS  = 2;
    parameter int NO_OF_SLAVES   = 3;
    parameter IDLE=2'b00,BUSY=2'b01,NONSEQ=2'b10,SEQ=2'b11; //for HTRANS
    parameter BYTE=3'b000, HALF_WORD=3'b001, WORD=3'b010;   //for HSIZE

endpackage : ahb_params_pkg
