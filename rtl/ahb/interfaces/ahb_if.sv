//interface to connect AHB master with slave
interface ahb_if;

    //AMBA AHB signals
    logic HCLK,                              //clock
    logic HRESETn,                           // reset controller
    logic [31:0] HADDR,                      // 32-bit system bus address
    logic [1:0] HTRASN,                      // NOSEQ, SEQ, IDLE, BUSY
    logic  HWRITE,                           // HIGH-write, LOW-read
    logic [2:0] HSIZE,                      //  transfer size: byte(8-bit), halfword(16-bit) or word(32-bit)
    logic [2:0] HBURST,                     // INCREMENT, WRAPPING. 4,8,16 beat burst supported.
    logic [3:0] HPROT,
    logic [31:0] HWDATA,
    logic HSELx,
    logic [31:0] HRDATA,
    logic HREADY,
    logic [1:0] HRESP,

    //ARBITRATION SIGNALS
    logic HBUSREQx,
    logic HLOCKx,
    logic HGRANTx,
    logic [3:0] HMASTER,
    logic HMASTLOCK,
    logic [15:0] HSPLITx

endinterface //ahb_if