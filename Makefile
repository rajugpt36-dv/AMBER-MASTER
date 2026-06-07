# =============================================================================
# File        : Makefile
# Description : AXI4-Lite UVM TB - Cadence Xcelium Build System
# Usage       :
#   make compile
#   make run     TEST=tc001_single_write_test
#   make gui     TEST=tc008_rand_mix_test
#   make cov
#   make regress
#   make clean
# =============================================================================

XRUN      = xrun
SIMVISION = simvision

FILELIST  = filelist.f
LOG_DIR   = logs
COV_DIR   = coverage_db
REGRESS_DIR = regress_results

# Default test
TEST      ?= tc008_rand_mix_test
NTXN      ?= 20
SEED      ?= 12345
VERBOSITY ?= UVM_MEDIUM

# Common xrun flags
XRUN_FLAGS  = -sv
XRUN_FLAGS += -uvm
XRUN_FLAGS += -uvmhome CDNS-1.2
XRUN_FLAGS += -access +rwc
XRUN_FLAGS += -timescale 1ns/1ps
XRUN_FLAGS += -coverage all
XRUN_FLAGS += -covfile cov.ccf
XRUN_FLAGS += -covworkdir $(COV_DIR)
XRUN_FLAGS += -seed $(SEED)
XRUN_FLAGS += +UVM_VERBOSITY=$(VERBOSITY)
XRUN_FLAGS += +NTXN=$(NTXN)

# All 15 UVM test class names
TESTS =  tc001_single_write_test    \
         tc002_single_read_test     \
         tc003_write_read_test      \
         tc004_seq_writes_test      \
         tc005_seq_reads_test       \
         tc006_rand_writes_test     \
         tc007_rand_reads_test      \
         tc008_rand_mix_test        \
         tc009_reset_idle_test      \
         tc010_reset_txn_test       \
         tc011_b2b_writes_test      \
         tc012_b2b_reads_test       \
         tc013_wstrb_all_test       \
         tc014_invalid_addr_test    \
         tc015_stress_test

.PHONY: all compile run gui waves cov regress clean help

all: compile run

# ---- compile -----------------------------------------------------------------
compile:
	@echo "=== Compiling AXI4-Lite UVM TB ==="
	@mkdir -p $(LOG_DIR)
	$(XRUN) -compile $(XRUN_FLAGS) -f $(FILELIST) \
		-log $(LOG_DIR)/compile.log
	@echo "=== Compile DONE ==="

# ---- run ---------------------------------------------------------------------
run:
	@echo "=== Running Test: $(TEST) ==="
	@mkdir -p $(LOG_DIR) $(COV_DIR)
	$(XRUN) $(XRUN_FLAGS) -f $(FILELIST) \
		+UVM_TESTNAME=$(TEST) \
		-log $(LOG_DIR)/$(TEST).log
	@echo "=== Run DONE: $(TEST) ==="

# ---- run with waves (SHM) ----------------------------------------------------
waves:
	@echo "=== Running with Waveforms: $(TEST) ==="
	@mkdir -p $(LOG_DIR) $(COV_DIR)
	$(XRUN) $(XRUN_FLAGS) -f $(FILELIST) \
		+UVM_TESTNAME=$(TEST) \
		-input waves.tcl \
		-log $(LOG_DIR)/$(TEST)_waves.log
	@echo "=== Waves Run DONE ==="

# ---- gui (SimVision) ---------------------------------------------------------
gui:
	@echo "=== Launching SimVision: $(TEST) ==="
	@mkdir -p $(LOG_DIR)
	$(XRUN) $(XRUN_FLAGS) -f $(FILELIST) \
		+UVM_TESTNAME=$(TEST) \
		-gui \
		-input simvision.tcl \
		-log $(LOG_DIR)/$(TEST)_gui.log

# ---- coverage ----------------------------------------------------------------
cov:
	@echo "=== Merging and Reporting Coverage ==="
	@mkdir -p $(LOG_DIR)
	imc -load $(COV_DIR) \
		-execcmd "report -detail -html -out $(COV_DIR)/cov_report" \
		-log $(LOG_DIR)/imc.log
	@echo "=== Coverage report: $(COV_DIR)/cov_report/index.html ==="

# ---- regression --------------------------------------------------------------
regress:
	@echo "=== Starting UVM Regression ==="
	@mkdir -p $(REGRESS_DIR) $(LOG_DIR) $(COV_DIR)
	@chmod +x regress.sh
	./regress.sh $(SEED) 2>&1 | tee $(REGRESS_DIR)/regress_summary.log
	@echo "=== Regression DONE ==="

# ---- clean -------------------------------------------------------------------
clean:
	rm -rf xcelium.d $(COV_DIR) $(LOG_DIR) $(REGRESS_DIR) .simvision
	rm -f  waves.vcd waves.shm *.trn *.dsn *.key *.log xrun.history
	@echo "=== Clean DONE ==="

# ---- help --------------------------------------------------------------------
help:
	@echo "AXI4-Lite UVM Verification Environment"
	@echo "======================================="
	@echo "  make compile                  - Compile only"
	@echo "  make run   TEST=<name>        - Run one test"
	@echo "  make waves TEST=<name>        - Run with waveform dump"
	@echo "  make gui   TEST=<name>        - Launch SimVision"
	@echo "  make cov                      - Merge + HTML coverage report"
	@echo "  make regress                  - Full 15-test regression"
	@echo "  make clean                    - Remove all artifacts"
	@echo ""
	@echo "UVM Test Names:"
	@for t in $(TESTS); do echo "    $$t"; done
	@echo ""
	@echo "Examples:"
	@echo "  make run TEST=tc015_stress_test NTXN=1000 SEED=42"
	@echo "  make run TEST=tc008_rand_mix_test VERBOSITY=UVM_HIGH"
