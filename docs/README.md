# AXI4-Lite UVM Verification Environment

## Overview

A complete, industry-grade UVM-based AXI4-Lite verification environment targeting **Cadence Xcelium** with **SimVision** GUI. Built using UVM-1.2 (CDNS), it verifies a Master-Slave AXI4-Lite fabric with no DUT — the environment generates, drives, monitors, checks, and measures coverage of all traffic.

| Attribute           | Value                              |
|---------------------|------------------------------------|
| Protocol            | AXI4-Lite (ARM AMBA 4.0)           |
| Addr / Data Width   | 32-bit / 32-bit                    |
| Transfer Type       | Single-beat only                   |
| Methodology         | UVM-1.2 (CDNS-1.2)                 |
| Simulator           | Cadence Xcelium (xrun)             |
| GUI                 | SimVision                          |
| Testcases           | 15 (TC001–TC015)                   |
| SVA Assertions      | 29 properties + 9 cover props      |
| Coverage Groups     | 8 covergroups + cross coverage     |

---

## Directory Structure

```
axi4lite_uvm_tb/
├── interface/
│   └── axi4lite_if.sv            # AXI4-Lite interface (3 clocking blocks, 3 modports)
├── rtl/
│   └── axi4lite_slave_bfm.sv     # Slave BFM module (4KB memory, AW+W+B, AR+R loops)
├── tb/
│   ├── axi4lite_pkg.sv           # UVM package (bundles all `include files)
│   ├── axi4lite_assertions.sv    # SVA assertions module (29 properties)
│   ├── tb_top.sv                 # Top-level: clock/reset, VIF config_db, run_test()
│   ├── transaction/
│   │   └── axi4lite_seq_item.sv  # uvm_sequence_item with constraints, do_copy/compare
│   ├── agent/
│   │   ├── axi4lite_config.sv    # uvm_object config (VIF, is_active, delays)
│   │   └── axi4lite_agent.sv     # uvm_agent (seqr+drv+mon, active/passive)
│   ├── sequencer/
│   │   └── axi4lite_sequencer.sv # uvm_sequencer parameterized to seq_item
│   ├── driver/
│   │   └── axi4lite_driver.sv    # uvm_driver: AW+W+B and AR+R protocol tasks
│   ├── monitor/
│   │   └── axi4lite_monitor.sv   # uvm_monitor: forked write + read channel observers
│   ├── scoreboard/
│   │   └── axi4lite_scoreboard.sv# uvm_scoreboard: ref model, byte-strobe check
│   ├── coverage/
│   │   └── axi4lite_coverage.sv  # uvm_subscriber: 8 covergroups + cross
│   ├── env/
│   │   └── axi4lite_env.sv       # uvm_env: builds/connects agent+scb+cov
│   ├── sequence/
│   │   ├── axi4lite_base_seq.sv  # uvm_sequence base with helper tasks
│   │   └── axi4lite_sequences.sv # 15 sequence classes (TC001-TC015)
│   └── test/
│       ├── axi4lite_base_test.sv # uvm_test base: build, reset, run_test_body()
│       └── axi4lite_tests.sv     # 15 test classes (TC001-TC015)
└── sim/
    ├── filelist.f                 # Xcelium compile order + flags
    ├── Makefile                   # All make targets
    ├── run.sh                     # Single test runner
    ├── regress.sh                 # Full 15-test regression
    ├── clean.sh                   # Remove all artifacts
    ├── simvision.tcl              # SimVision auto-setup
    ├── waves.tcl                  # Batch SHM waveform dump
    └── cov.ccf                    # Xcelium coverage config
```

---

## UVM Environment Architecture

```
 ┌──────────────────────────────────────────────────────────┐
 │                     uvm_test                             │
 │  (tc001..tc015_test)   run_test_body() -> seq.start()    │
 └────────────────────────┬─────────────────────────────────┘
                          │ uvm_config_db
 ┌────────────────────────▼─────────────────────────────────┐
 │                    axi4lite_env                           │
 │  ┌─────────────────────────────────────────────────────┐ │
 │  │              axi4lite_agent (UVM_ACTIVE)            │ │
 │  │                                                     │ │
 │  │  ┌────────────┐  seq_item  ┌──────────────────────┐ │ │
 │  │  │ Sequencer  │ ─────────▶ │      Driver          │ │ │
 │  │  │ (seqr)     │            │  write/read tasks    │ │ │
 │  │  └────────────┘            └──────────┬───────────┘ │ │
 │  │                                       │drives        │ │
 │  │                            ┌──────────▼───────────┐ │ │
 │  │                            │   axi4lite_if        │ │ │
 │  │                            │  (clocking blocks)   │ │ │
 │  │                            └──────────┬───────────┘ │ │
 │  │                                       │observes      │ │
 │  │  ┌─────────────────────────────────── │ ──────────┐ │ │
 │  │  │ Monitor  (forked W-ch + R-ch)      │           │ │ │
 │  │  └──────────────────┬────────────────────────────┘ │ │
 │  │           analysis  │ port (ap)                     │ │
 │  └───────────────────── │ ───────────────────────────┘ │
 │                ┌────────┴──────────┐                    │
 │                ▼                   ▼                    │
 │  ┌─────────────────┐   ┌──────────────────────────┐    │
 │  │  Scoreboard     │   │  Coverage (subscriber)   │    │
 │  │  (ref mem model)│   │  (8 covergroups + cross) │    │
 │  └─────────────────┘   └──────────────────────────┘    │
 └──────────────────────────────────────────────────────────┘
          │ tb_top binds
          ▼
 ┌─────────────────────┐      ┌─────────────────────────┐
 │   Slave BFM Module  │      │  SVA Assertions Module  │
 │   (4KB mem model)   │      │  (29 properties)        │
 └─────────────────────┘      └─────────────────────────┘
```

---

## Quick Start

```bash
cd axi4lite_uvm_tb/sim

# Compile
make compile

# Run default test (TC008 random mix, 20 transactions)
make run

# Run specific test
make run TEST=tc003_write_read_test

# Run stress test
make run TEST=tc015_stress_test NTXN=1000 SEED=42

# Run with high verbosity
make run TEST=tc001_single_write_test VERBOSITY=UVM_HIGH

# Launch SimVision
make gui TEST=tc008_rand_mix_test

# Run full regression
make regress

# Generate coverage report
make cov

# Cleanup
make clean
```

---

## Running Tests (plusarg reference)

| Plusarg              | Default           | Description                       |
|----------------------|-------------------|-----------------------------------|
| `+UVM_TESTNAME=`     | `tc008_rand_mix_test` | UVM test class name           |
| `+UVM_VERBOSITY=`    | `UVM_MEDIUM`      | UVM verbosity level               |
| `+NTXN=`             | `20`              | Number of transactions            |
| `+SEED=`             | `12345`           | Random seed                       |

```bash
xrun -f filelist.f +UVM_TESTNAME=tc015_stress_test +NTXN=1000 +SEED=99
```

---

## UVM Component Descriptions

### axi4lite_seq_item
- Extends `uvm_sequence_item`
- Rand fields: `op` (AXI_WRITE/AXI_READ), `addr`, `data`, `wstrb`
- Constraints: word alignment, address in [0x000:0xFFC], WSTRB ≠ 0
- Implements: `do_copy`, `do_compare`, `convert2string`, `do_print`
- Field registration: `uvm_field_*` macros for clone/print/compare

### axi4lite_config
- Extends `uvm_object`
- Holds: `virtual axi4lite_if vif`, `is_active`, `has_coverage`, timing knobs
- Distributed via `uvm_config_db` from test to all sub-components

### axi4lite_sequencer
- Parameterized `uvm_sequencer #(axi4lite_seq_item)`
- No special logic — pure pass-through

### axi4lite_driver
- Extends `uvm_driver #(axi4lite_seq_item)`
- Retrieves config via `config_db`; gets VIF from config
- `drive_write()`: AW phase → W phase → B phase with configurable wait states
- `drive_read()`: AR phase → R phase
- Per-channel timeout detection with `uvm_error`

### axi4lite_monitor
- Extends `uvm_monitor`
- Forks two forever loops: `monitor_write_channel()` and `monitor_read_channel()`
- Each captures complete handshake, creates seq_item, writes to `uvm_analysis_port`

### axi4lite_agent
- Extends `uvm_agent`
- Builds seqr + drv + mon when `UVM_ACTIVE`; only mon when `UVM_PASSIVE`
- Connects `drv.seq_item_port → seqr.seq_item_export`
- Relays `mon.ap → agent.ap`

### axi4lite_scoreboard
- Extends `uvm_scoreboard`
- `uvm_analysis_imp` receives items from monitor
- Reference memory: `bit [31:0] expected_mem [bit [31:0]]` (associative array)
- `check_write()`: applies byte strobes to ref model, verifies BRESP=OKAY
- `check_read()`: compares rdata vs expected_mem, verifies RRESP=OKAY

### axi4lite_coverage
- Extends `uvm_subscriber #(axi4lite_seq_item)`
- `write()` called automatically by analysis port
- 8 covergroups: op, address range, wstrb, data pattern, response, cross×2, transfer size

### axi4lite_env
- Extends `uvm_env`
- Builds agent, scoreboard, coverage
- `connect_phase`: `agent.ap → scb.analysis_export` and `agent.ap → cov.analysis_export`

### axi4lite_base_test / axi4lite_*_test
- `base_test`: retrieves VIF, creates config, builds env, drives reset, calls `run_test_body()`
- Each `tc0XX_*_test` overrides `run_test_body()` to start its named sequence

---

## Assertion Summary (29 properties)

| Channel | Count | IDs                         |
|---------|-------|-----------------------------|
| AW      | 5     | AST_AW01–AW05               |
| W       | 6     | AST_W01–W06                 |
| B       | 4     | AST_B01–B04                 |
| AR      | 5     | AST_AR01–AR05               |
| R       | 5     | AST_R01–R05                 |
| Reset   | 5     | AST_RST01–RST05             |
| Cover   | 9     | COV_AW/W/B/AR/R + wait states|

---

## Coverage Summary

| Group                | Bins | Description                          |
|----------------------|------|--------------------------------------|
| `cg_operation`       | 2    | AXI_WRITE, AXI_READ                  |
| `cg_address_range`   | 3    | Low/Mid/High                         |
| `cg_wstrb`           | 15   | All non-zero strobe combinations     |
| `cg_data_pattern`    | 4    | zeros, ones, walk-one, random        |
| `cg_response`        | 8    | BRESP×4, RRESP×4                     |
| `cg_cross_addr_op`   | 6    | addr[2] × op                         |
| `cg_cross_addr_wstrb`| 6    | addr[2] × strobe-group               |
| `cg_transfer_size`   | 4    | 1/2/3/4 active byte lanes            |

---

## Debug Tips

| Symptom                        | Action                                            |
|--------------------------------|---------------------------------------------------|
| `NO_VIF` fatal                 | Ensure `config_db::set(null,"uvm_test_top","vif")` in tb_top |
| `NO_CFG` fatal                 | Check config_db set path in test build_phase      |
| AWREADY/WREADY timeout error   | Check slave BFM is running; check rst_n polarity  |
| Scoreboard data mismatch       | Enable `UVM_HIGH` verbosity; trace MON_RD entries |
| Coverage hole in `cg_wstrb`    | Add TC013 to regression; run more random seeds    |
| UVM_FATAL in run_test_body     | Ensure child test overrides the virtual task      |
| Assertion fail AST_RST01       | Driver not calling `reset_signals()` on rst_n     |
