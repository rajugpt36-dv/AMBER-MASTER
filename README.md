# AXI4-Lite UVM Testbench (Windows / Questa)

This repository contains an AXI4-Lite UVM verification environment perfectly tuned for local simulation using Mentor/Siemens QuestaSim on Windows.

All simulation scripts are located in the `sim` directory. To run any of the commands below, first open PowerShell and navigate to the `sim` directory:
```powershell
cd sim
```

## 1. Run a Single Test (Fast Console Mode)
Compiles the design and runs a single test case in the console (no GUI). This is the fastest way to run a test.

**Command:**
```powershell
.\run_questa.bat <test_name>
```

**Example:**
```powershell
.\run_questa.bat tc011_b2b_writes_test
```
*(If no test name is provided, it defaults to `tc011_b2b_writes_test`)*

## 2. Run a Single Test (GUI & Waveforms)
Compiles the design and launches the QuestaSim GUI. It automatically loads all signals into the waveform viewer and runs the simulation to completion.

**Command:**
```powershell
.\run_questa_gui.bat <test_name>
```

**Example:**
```powershell
.\run_questa_gui.bat tc015_stress_test
```

## 3. Run the Full Regression Suite
Runs all 15 test cases sequentially without GUI. It prints a clean `PASS/FAIL` summary table at the very end of the console output.

**Command:**
```powershell
.\regress_questa.bat
```

## 4. Run a Single Test (with Coverage)
Compiles the design with full coverage enabled (Branch, Condition, Expression, Statement, FSM), runs a specific test, and generates a graphical HTML coverage report.

**Command:**
```powershell
.\cov_questa.bat <test_name>
```

**Example:**
```powershell
.\cov_questa.bat tc008_rand_mix_test
```
*After completion, open `sim\covhtmlreport\index.html` in your web browser to view the report.*

## 5. Run Full Coverage Regression
The ultimate verification command. It compiles with coverage enabled, runs all 15 tests sequentially, merges all 15 individual coverage databases into one master database, and generates a massive HTML report showing the cumulative coverage of the entire suite.

**Command:**
```powershell
.\cov_regress_questa.bat
```

*After completion, open `sim\merged_covhtmlreport\index.html` in your web browser to view the report.*

## 6. View Coverage in Questa GUI
If you prefer to view the coverage database directly inside the QuestaSim GUI (instead of the HTML website), you can load the merged `.ucdb` file natively.

**Command:**
```powershell
vsim -viewcov coverage_db\merged_coverage.ucdb
```

---

### Available Test Cases
You can pass any of the following test names as arguments to the scripts above:

*   `tc001_single_write_test`
*   `tc002_single_read_test`
*   `tc003_write_read_test`
*   `tc004_seq_writes_test`
*   `tc005_seq_reads_test`
*   `tc006_rand_writes_test`
*   `tc007_rand_reads_test`
*   `tc008_rand_mix_test`
*   `tc009_reset_idle_test`
*   `tc010_reset_txn_test`
*   `tc011_b2b_writes_test`
*   `tc012_b2b_reads_test`
*   `tc013_wstrb_all_test`
*   `tc014_invalid_addr_test`
*   `tc015_stress_test`
