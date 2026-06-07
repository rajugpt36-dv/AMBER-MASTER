#!/bin/bash
# =============================================================================
# File    : run.sh
# Usage   : ./run.sh [UVM_TESTNAME] [NTXN] [SEED] [VERBOSITY]
# Example : ./run.sh tc008_rand_mix_test 20 12345 UVM_MEDIUM
# =============================================================================
set -e
TEST=${1:-tc008_rand_mix_test}
NTXN=${2:-20}
SEED=${3:-12345}
VERB=${4:-UVM_MEDIUM}
SIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SIM_DIR}/logs"
COV_DIR="${SIM_DIR}/coverage_db"
mkdir -p "${LOG_DIR}" "${COV_DIR}"

echo "============================================================"
echo "  AXI4-Lite UVM Verification - Cadence Xcelium"
echo "  Test      : ${TEST}"
echo "  TXNs      : ${NTXN}"
echo "  Seed      : ${SEED}"
echo "  Verbosity : ${VERB}"
echo "============================================================"

xrun \
    -sv -uvm -uvmhome CDNS-1.2 \
    -access +rwc \
    -timescale 1ns/1ps \
    -coverage all \
    -covfile cov.ccf \
    -covworkdir "${COV_DIR}/${TEST}" \
    -seed "${SEED}" \
    -f filelist.f \
    +UVM_TESTNAME="${TEST}" \
    +UVM_VERBOSITY="${VERB}" \
    +NTXN="${NTXN}" \
    -log "${LOG_DIR}/${TEST}.log" \
    2>&1 | tee "${LOG_DIR}/${TEST}_console.log"

EXIT=$?
echo "============================================================"
[ ${EXIT} -eq 0 ] && echo "  RESULT : PASSED" || echo "  RESULT : FAILED (exit=${EXIT})"
echo "============================================================"
exit ${EXIT}
