# amba_ahb_apb_design_verification
## Design and Verification of a Multi-Master AMBA AHB Subsystem with AHB-to-APB Bridge

This project implements a complete AMBA system bus architecture, including a multi-master AHB subsystem, an AHB-to-APB bridge, and a set of APB peripherals. It features full synthesizable RTL, protocol-accurate behavior and a UVM testbench with constrained-random tests, coverage, assertions, and A scoreboard for end-to-end functional verification.

## 📌 Project Overview
## ✔ AHB Subsystem (Phase-1)

**Two AHB masters:**

- CPU-like master (single + short bursts, optional locked transfers)
- DMA-like master (long bursts, high bandwidth)

**AHB arbiter (fixed-priority / round-robin)**

**Address decoder for slave selection**

**AHB slaves:**

- Fast SRAM slave (OKAY responses)
- AHB-to-APB bridge
- SPLIT/RETRY/ERROR-capable slow slave
- Default error slave

## ✔ APB Subsystem (Phase-2)

- APB interface with standard 2-phase protocol (Setup + Enable)
- One or more simple APB slaves (GPIO/UART/timer example)
- Implements cycle-accurate APB SETUP/ENABLE timing with correct PSEL, PENABLE, PWRITE, and PREADY handshakes.

## 🧩 Key Features
**Design**

Synthesizable RTL in SystemVerilog
Full AHB protocol support:
- NONSEQ/SEQ transfers
- INCR/WRAP bursts
- OKAY/ERROR/RETRY/SPLIT responses
- 1-KB burst boundary rules
Clean AHB/APB interface definitions (interface construct)

**Verification (UVM)**

Two AHB master agents (CPU + DMA)
Constrained-random sequences for bursts, sizes, addresses
Scoreboard with reference memory model
Functional coverage for transfers, arbitration, HRESP types
Assertions for protocol timing (HREADY, HRESP rules)
Directed tests for SPLIT/RETRY/ERROR and arbitration corner cases

## 📂 Repository Structure
```
ahb_apb_design_verification/
├── rtl/
│   ├── ahb/
│   │   ├── interfaces/
│   │   │   └── ahb_if.sv
│   │   ├── masters/
│   │   ├── slaves/
│   │   ├── infra/        # arbiter + decoder
│   │   └── ahb_top.sv
│   ├── apb/
│   │   ├── apb_if.sv
│   │   └── apb_slaves/
│   └── bridge/
│       └── ahb_apb_bridge.sv
│
├── tb/
│   ├── ahb_if.sv
│   ├── uvm/
│   │   ├── agents/
│   │   ├── env/
│   │   ├── sequences/
│   │   ├── scoreboard/
│   │   └── coverage/
│   ├── tests/
│   └── assertions/
│
├── sim/
│   ├── compile.f
│   ├── run.f
│   └── waves/
│
└── docs/
    ├── block_diagrams/
    └── verification_plan.md
```

## 📘 References

- ARM AMBA AHB/ASB/APB Specifications
- ARM AMBA AXI4 Specification (for future extension)
- UVM User Guide
- Doulos / Verification Academy resources
