// -------------------------------------------------
// AHB Interface using ahb_params_pkg
// -------------------------------------------------


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
    logic [NO_OF_SLAVES-1:0]       HSEL;            // Decoder: slave select (one-hot)
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
    modport master_mp (
        input   HCLK,
                HRESETn,
                HRDATA,
                HREADY,
                HRESP,
                HGRANT,
                HMASTLOCK,

        output  HADDR,
                HTRANS,
                HWRITE,
                HSIZE,
                HBURST,
                HPROT,
                HWDATA,
                HBUSREQ,
                HLOCK
    );


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
                HSEL,
                HMASTER,
                HMASTLOCK,

        output  HRDATA,
                HREADY,
                HRESP,
                HSPLIT
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


    modport monitor_mp (
        input   HCLK,
                HRESETn,
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
                HSEL,
                HBUSREQ,
                HLOCK,
                HGRANT,
                HMASTER,
                HMASTLOCK,
                HSPLIT
    );



endinterface : ahb_if
