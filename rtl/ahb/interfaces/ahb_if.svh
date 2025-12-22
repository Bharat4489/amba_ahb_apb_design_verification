// -------------------------------------------------
// AHB Interface using ahb_params_pkg
// -------------------------------------------------

`timescale 1ns/1ps

interface ahb_if;
    import ahb_params_pkg::*;
    // -------------------------------------------------
    // Global signals
    // -------------------------------------------------
    logic                          HCLK;            // Clock source
    logic                          HRESETn;         // Reset controller (active low)

    // -------------------------------------------------
    // Address and control signals (from master)
    // -------------------------------------------------
    logic [ADDR_WIDTH-1:0]         HADDR;           // Master: system bus address
    logic [1:0]                    HTRANS;          // Master: transfer type (IDLE, BUSY, NONSEQ, SEQ)
    logic                          HWRITE;          // Master: HIGH = write, LOW = read
    logic [2:0]                    HSIZE;           // Master: transfer size (byte, halfword, word)
    logic [2:0]                    HBURST;          // Master: burst type (SINGLE, INCR, WRAP)
    logic [3:0]                    HPROT;           // Master: protection control

    // -------------------------------------------------
    // Data signals
    // -------------------------------------------------
    logic [DATA_WIDTH-1:0]         HWDATA;          // Master: write data bus
    logic [DATA_WIDTH-1:0]         HRDATA;          // Slave : read data bus

    // -------------------------------------------------
    // Slave select and response signals
    // -------------------------------------------------
    logic                          HSEL_SRAM;       // Decoder: select SRAM_slave
    logic                          HSEL_DEFAULT;    // Decoder: select DEFAULT_slave
    logic                          HREADY;          // Slave : transfer done / wait-state control
    logic [1:0]                    HRESP;           // Slave : response (OKAY, ERROR, RETRY, SPLIT)

    // -------------------------------------------------
    // Arbitration signals
    // -------------------------------------------------
    logic [NO_OF_MASTERS-1:0]      HBUSREQ;         // Master: bus request
    logic [NO_OF_MASTERS-1:0]      HLOCK;           // Master: locked transfer request
    logic [NO_OF_MASTERS-1:0]      HGRANT;          // Arbiter: bus grant
    logic [$clog2(NO_OF_MASTERS)-1:0] HMASTER;     // Arbiter: current master number
    logic                          HMASTLOCK;      // Arbiter: locked sequence indication
    logic [NO_OF_MASTERS-1:0]      HSPLIT;          // Slave : split completion per master


    // -------------------------------------------------
    // modport- master_mp, slave_mp, arbiter_mp, monitor_mp, 
    // -------------------------------------------------
    // -------------------------------------------------
    // Master modport (used by UVM master driver)
    // -------------------------------------------------

        clocking driver_cb @ (posedge HCLK);
                default input #1step output #1step; // small skew; tune as needed

                // outputs (driven by master)
                output  HADDR,
                        HTRANS,
                        HWRITE,
                        HSIZE,
                        HBURST,
                        HPROT,
                        HWDATA,
                        HBUSREQ,
                        HLOCK;

                // inputs (sampled by master)
                input   HRESETn,
                        HRDATA,
                        HREADY,
                        HRESP,
                        HGRANT,
                        HMASTLOCK;
        endclocking

    modport master_mp (clocking driver_cb);

    clocking monitor_cb @ (posedge HCLK);
        default input #1step; // small skew; tune as needed

        input   HRESETn,
                HADDR,
                HTRANS,
                HWRITE,
                HSIZE,
                HBURST,
                HPROT,
                HWDATA,
                HRDATA,
                HREADY,
                HRESP,
                HBUSREQ,
                HLOCK,
                HGRANT,
                HMASTER,
                HMASTLOCK,
                HSPLIT;
    endclocking

        modport monitor_mp (clocking monitor_cb);

        //--------------------
        //RTL modport
        //--------------------
        modport slave_mp (
        input   HCLK,
                HRESETn,
                HADDR,
                HTRANS,
                HWRITE,
                HSIZE,
                HBURST,
                HPROT,
                HWDATA,
                HMASTER,
                HMASTLOCK,
                HSEL_DEFAULT,
                HSEL_SRAM,

        // output  HRDATA,      using ahb_top to connect local output of slaves thus avoiding multi drives
        //         HREADY,
        //         HRESP,
        //         HSPLIT
        );


        modport arbiter_mp (
        input   HCLK,
                HRESETn,
                HBUSREQ,
                HLOCK,
                HSPLIT,

        output  HGRANT,
                HMASTER,
                HMASTLOCK
        );

        modport decoder_mp (
        input   HCLK,
                HRESETn,
                HADDR,
                HTRANS,

        output  HSEL_DEFAULT,
                HSEL_SRAM
                
        );

endinterface : ahb_if