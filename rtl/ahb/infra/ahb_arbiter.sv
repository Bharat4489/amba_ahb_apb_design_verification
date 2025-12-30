/*
The arbiter samples HBUSREQ, HLOCK, and HSPLIT, 
and updates HGRANT only when HREADY is asserted. 
It enforces one-hot grants, respects locked transfers, 
and removes split masters until HSPLIT re-enables them.
*/
module ahb_arbiter (
    ahb_if.arbiter_mp arbiter_if
);

endmodule