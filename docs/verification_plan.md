# AXI4-Lite UVM Verification Plan

## Document Information

| Field        | Value                                   |
|--------------|-----------------------------------------|
| Project      | AXI4-Lite UVM Verification Environment  |
| Version      | 1.0                                     |
| Methodology  | UVM-1.2 (Cadence CDNS-1.2)             |
| Simulator    | Cadence Xcelium                         |
| Status       | Released                                |

---

## Environment Architecture Summary

| Component            | UVM Base Class              | Role                                           |
|----------------------|-----------------------------|------------------------------------------------|
| `axi4lite_seq_item`  | `uvm_sequence_item`         | Transaction object with constraints            |
| `axi4lite_config`    | `uvm_object`                | Agent configuration (VIF, delays, mode)        |
| `axi4lite_sequencer` | `uvm_sequencer`             | Sequence-to-driver arbiter                     |
| `axi4lite_driver`    | `uvm_driver`                | AXI4-Lite protocol driver via clocking block   |
| `axi4lite_monitor`   | `uvm_monitor`               | Non-intrusive bus observer → analysis port     |
| `axi4lite_agent`     | `uvm_agent`                 | Bundles seqr+drv+mon, active/passive mode      |
| `axi4lite_scoreboard`| `uvm_scoreboard`            | Reference memory model + pass/fail checker     |
| `axi4lite_coverage`  | `uvm_subscriber`            | Functional coverage sampler (8 covergroups)    |
| `axi4lite_env`       | `uvm_env`                   | Builds and connects all sub-components         |
| `axi4lite_base_test` | `uvm_test`                  | Base test: reset, config, env build            |
| TC001–TC015 tests    | `axi4lite_base_test`        | Individual test scenarios                      |
| TC001–TC015 seqs     | `axi4lite_base_seq`         | Sequence bodies for each scenario              |

---

## UVM Phase Usage

| Phase                    | Used By                   | Action                                              |
|--------------------------|---------------------------|-----------------------------------------------------|
| `build_phase`            | test, env, agent, drv/mon | Create components, get config_db, build hierarchy   |
| `connect_phase`          | agent, env                | TLM port connections (AP → scoreboard, coverage)   |
| `start_of_simulation`    | env                       | Print UVM topology                                  |
| `run_phase`              | test, driver, monitor     | Reset sequence, run sequences, observe interface    |
| `report_phase`           | test, scb, coverage, drv  | Print pass/fail counts, coverage percentages        |

---

## Feature Coverage Matrix

| Feature ID | Feature                        | Sequences                 | Assertions         | Priority |
|------------|--------------------------------|---------------------------|--------------------|----------|
| F001       | Single AXI4-Lite Write         | TC001                     | AW01-05, W01-06    | P1       |
| F002       | Single AXI4-Lite Read          | TC002                     | AR01-05, R01-05    | P1       |
| F003       | Write-Read Data Integrity       | TC003                     | B01-04, R01-05     | P1       |
| F004       | Sequential Write Burst          | TC004                     | AW01-05            | P1       |
| F005       | Sequential Read Burst           | TC005                     | AR01-05            | P1       |
| F006       | Randomized Write Traffic        | TC006                     | W01-06             | P1       |
| F007       | Randomized Read Traffic         | TC007                     | R01-05             | P1       |
| F008       | Mixed Read/Write Traffic        | TC008                     | All channels       | P1       |
| F009       | Reset During Idle               | TC009                     | RST01-05           | P2       |
| F010       | Reset During Active Transaction | TC010                     | RST01-05           | P2       |
| F011       | Back-to-Back Writes             | TC011                     | AW01, W01, B01     | P2       |
| F012       | Back-to-Back Reads              | TC012                     | AR01, R01-02       | P2       |
| F013       | All WSTRB Combinations          | TC013                     | W03, W06           | P2       |
| F014       | Out-of-Range Address            | TC014                     | AW04, AR04         | P3       |
| F015       | Stress / Corner Cases           | TC015                     | All channels       | P2       |
| F016       | AWVALID Stability               | All write TCs             | AST_AW01           | P1       |
| F017       | AWADDR Stability                | All write TCs             | AST_AW02           | P1       |
| F018       | AWREADY Liveness                | All write TCs             | AST_AW03           | P1       |
| F019       | AWADDR Alignment                | All write TCs             | AST_AW04           | P1       |
| F020       | No X/Z on AWADDR                | All write TCs             | AST_AW05           | P1       |
| F021       | WVALID/WDATA/WSTRB Stability    | All write TCs             | AST_W01-03         | P1       |
| F022       | WREADY Liveness                 | All write TCs             | AST_W04            | P1       |
| F023       | WSTRB Non-Zero Rule             | TC006, TC013              | AST_W06            | P1       |
| F024       | BVALID After Write              | All write TCs             | AST_B01            | P1       |
| F025       | BVALID/BRESP Stability          | All write TCs             | AST_B02-03         | P1       |
| F026       | BREADY Liveness                 | All write TCs             | AST_B04            | P1       |
| F027       | ARVALID/ARADDR Stability        | All read TCs              | AST_AR01-02        | P1       |
| F028       | ARREADY Liveness                | All read TCs              | AST_AR03           | P1       |
| F029       | ARADDR Alignment                | All read TCs              | AST_AR04           | P1       |
| F030       | RVALID After Read               | All read TCs              | AST_R01            | P1       |
| F031       | RVALID/RDATA Stability          | All read TCs              | AST_R02-03         | P1       |
| F032       | RREADY Liveness                 | All read TCs              | AST_R04            | P1       |
| F033       | No X/Z on RDATA                 | All read TCs              | AST_R05            | P1       |
| F034       | All VALIDs Clear After Reset    | TC009, TC010              | AST_RST01-05       | P1       |

---

## Testcase Descriptions

| TC_ID | UVM Test Class             | Sequence Class             | TXN Count | Description                          |
|-------|----------------------------|----------------------------|-----------|--------------------------------------|
| TC001 | tc001_single_write_test    | tc001_single_write_seq     | 1         | Write 0xCAFEBABE to 0x100            |
| TC002 | tc002_single_read_test     | tc002_single_read_seq      | 1         | Read from address 0x100              |
| TC003 | tc003_write_read_test      | tc003_write_read_seq       | 2         | Write then read same address         |
| TC004 | tc004_seq_writes_test      | tc004_seq_writes_seq       | 20        | Sequential word-aligned writes       |
| TC005 | tc005_seq_reads_test       | tc005_seq_reads_seq        | 20        | Sequential word-aligned reads        |
| TC006 | tc006_rand_writes_test     | tc006_rand_writes_seq      | 20        | Fully randomized write transactions  |
| TC007 | tc007_rand_reads_test      | tc007_rand_reads_seq       | 20        | Fully randomized read transactions   |
| TC008 | tc008_rand_mix_test        | tc008_rand_mix_seq         | 20        | Random 50/50 read-write mix          |
| TC009 | tc009_reset_idle_test      | tc009_reset_idle_seq       | 1         | Reset asserted while bus is idle     |
| TC010 | tc010_reset_txn_test       | tc010_reset_txn_seq        | 5+5       | Reset injected mid-transaction       |
| TC011 | tc011_b2b_writes_test      | tc011_b2b_writes_seq       | 20        | Back-to-back writes, zero gaps       |
| TC012 | tc012_b2b_reads_test       | tc012_b2b_reads_seq        | 20        | Back-to-back reads, zero gaps        |
| TC013 | tc013_wstrb_all_test       | tc013_wstrb_all_seq        | 30        | All 15 WSTRB combinations + readback |
| TC014 | tc014_invalid_addr_test    | tc014_invalid_addr_seq     | 2         | OOR address write + read             |
| TC015 | tc015_stress_test          | tc015_stress_seq           | 1000      | 1000 random R/W stress transactions  |

---

## Assertion Summary

| ID           | Channel | Rule                                      | Severity |
|--------------|---------|-------------------------------------------|----------|
| AST_AW01     | AW      | AWVALID stable until AWREADY              | ERROR    |
| AST_AW02     | AW      | AWADDR stable while AWVALID              | ERROR    |
| AST_AW03     | AW      | AWREADY within MAX_WAIT cycles            | ERROR    |
| AST_AW04     | AW      | AWADDR[1:0] == 2'b00 (word aligned)      | ERROR    |
| AST_AW05     | AW      | No X/Z on AWADDR when AWVALID            | ERROR    |
| AST_W01      | W       | WVALID stable until WREADY               | ERROR    |
| AST_W02      | W       | WDATA stable while WVALID               | ERROR    |
| AST_W03      | W       | WSTRB stable while WVALID               | ERROR    |
| AST_W04      | W       | WREADY within MAX_WAIT cycles            | ERROR    |
| AST_W05      | W       | No X/Z on WDATA when WVALID             | ERROR    |
| AST_W06      | W       | WSTRB != 4'b0000 when WVALID            | ERROR    |
| AST_B01      | B       | BVALID after AW+W handshake              | ERROR    |
| AST_B02      | B       | BVALID stable until BREADY              | ERROR    |
| AST_B03      | B       | BRESP stable while BVALID              | ERROR    |
| AST_B04      | B       | BREADY within MAX_WAIT cycles           | ERROR    |
| AST_AR01     | AR      | ARVALID stable until ARREADY            | ERROR    |
| AST_AR02     | AR      | ARADDR stable while ARVALID            | ERROR    |
| AST_AR03     | AR      | ARREADY within MAX_WAIT cycles          | ERROR    |
| AST_AR04     | AR      | ARADDR[1:0] == 2'b00 (word aligned)    | ERROR    |
| AST_AR05     | AR      | No X/Z on ARADDR when ARVALID          | ERROR    |
| AST_R01      | R       | RVALID after AR handshake               | ERROR    |
| AST_R02      | R       | RVALID stable until RREADY             | ERROR    |
| AST_R03      | R       | RDATA stable while RVALID             | ERROR    |
| AST_R04      | R       | RREADY within MAX_WAIT cycles          | ERROR    |
| AST_R05      | R       | No X/Z on RDATA when RVALID           | ERROR    |
| AST_RST01    | ALL     | AWVALID deasserted after rst_n         | ERROR    |
| AST_RST02    | ALL     | WVALID  deasserted after rst_n         | ERROR    |
| AST_RST03    | ALL     | ARVALID deasserted after rst_n         | ERROR    |
| AST_RST04    | ALL     | BVALID  deasserted after rst_n         | ERROR    |
| AST_RST05    | ALL     | RVALID  deasserted after rst_n         | ERROR    |

---

## Functional Coverage Closure Criteria

| Metric                      | Target | Tool         |
|-----------------------------|--------|--------------|
| Functional Covergroup       | ≥ 95%  | IMC / Xcelium|
| Toggle Coverage             | ≥ 90%  | Xcelium      |
| Branch Coverage             | ≥ 90%  | Xcelium      |
| Statement Coverage          | ≥ 95%  | Xcelium      |
| Assertion Pass Rate         | 100%   | Xcelium SVA  |
| Regression Pass Rate        | 100%   | regress.sh   |

---

## Risk Register

| Risk                              | Mitigation Strategy                                         |
|-----------------------------------|-------------------------------------------------------------|
| TLM port connection mismatch      | Verified connect_phase: agent.ap → scb + cov exports       |
| config_db path errors             | All paths use `this,"*","cfg"` pattern in build_phase       |
| Slave BFM AW/W race condition     | Independent forever loops; no shared state between channels |
| Reset injection affecting monitor | Monitor uses `disable iff (!rst_n)` equivalent in forever   |
| WSTRB coverage holes              | TC013 explicitly drives all 15 non-zero strobe values       |
| Sequence randomization failure    | `uvm_fatal` on failed randomize(); seed logged per run      |
| Stress test mailbox overflow      | UVM sequencer handles backpressure natively                 |
