#!/bin/bash
# =============================================================================
# File    : regress.sh
# Usage   : ./regress.sh [SEED]
# =============================================================================
SEED=${1:-12345}
SIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SIM_DIR}/logs"
REGRESS_DIR="${SIM_DIR}/regress_results"
COV_DIR="${SIM_DIR}/coverage_db"
REPORT="${REGRESS_DIR}/regression_summary.txt"
mkdir -p "${LOG_DIR}" "${REGRESS_DIR}" "${COV_DIR}"

declare -A NTXN
NTXN["tc001_single_write_test"]=1
NTXN["tc002_single_read_test"]=1
NTXN["tc003_write_read_test"]=2
NTXN["tc004_seq_writes_test"]=20
NTXN["tc005_seq_reads_test"]=20
NTXN["tc006_rand_writes_test"]=20
NTXN["tc007_rand_reads_test"]=20
NTXN["tc008_rand_mix_test"]=20
NTXN["tc009_reset_idle_test"]=1
NTXN["tc010_reset_txn_test"]=5
NTXN["tc011_b2b_writes_test"]=20
NTXN["tc012_b2b_reads_test"]=20
NTXN["tc013_wstrb_all_test"]=30
NTXN["tc014_invalid_addr_test"]=2
NTXN["tc015_stress_test"]=1000

PASS=0; FAIL=0; FAILED_LIST=()
START=$(date +%s)

echo "============================================================" | tee "${REPORT}"
echo "  AXI4-Lite UVM Regression  -  $(date)"                      | tee -a "${REPORT}"
echo "  Seed: ${SEED}"                                              | tee -a "${REPORT}"
echo "============================================================" | tee -a "${REPORT}"

for TEST in "${!NTXN[@]}"; do
    N="${NTXN[$TEST]}"
    LOG="${LOG_DIR}/${TEST}.log"
    printf "  %-40s ... " "${TEST}" | tee -a "${REPORT}"

    xrun -sv -uvm -uvmhome CDNS-1.2 \
        -access +rwc -timescale 1ns/1ps \
        -coverage all -covfile cov.ccf \
        -covworkdir "${COV_DIR}/${TEST}" \
        -seed "${SEED}" -f filelist.f \
        +UVM_TESTNAME="${TEST}" +NTXN="${N}" \
        +UVM_VERBOSITY=UVM_LOW \
        -log "${LOG}" > /dev/null 2>&1
    CODE=$?

    if [ ${CODE} -eq 0 ] && ! grep -q "UVM_ERROR\|UVM_FATAL\|TEST FAILED" "${LOG}" 2>/dev/null; then
        echo "PASS" | tee -a "${REPORT}"; PASS=$((PASS+1))
    else
        echo "FAIL" | tee -a "${REPORT}"; FAIL=$((FAIL+1)); FAILED_LIST+=("${TEST}")
    fi
done

END=$(date +%s)
echo ""                                                             | tee -a "${REPORT}"
echo "============================================================" | tee -a "${REPORT}"
echo "  REGRESSION SUMMARY"                                        | tee -a "${REPORT}"
echo "  Total  : $((PASS+FAIL))"                                   | tee -a "${REPORT}"
echo "  Passed : ${PASS}"                                          | tee -a "${REPORT}"
echo "  Failed : ${FAIL}"                                          | tee -a "${REPORT}"
echo "  Time   : $((END-START))s"                                  | tee -a "${REPORT}"
echo "============================================================" | tee -a "${REPORT}"
if [ ${FAIL} -gt 0 ]; then
    echo "  FAILED TESTS:" | tee -a "${REPORT}"
    for t in "${FAILED_LIST[@]}"; do echo "    - ${t}" | tee -a "${REPORT}"; done
    echo "  STATUS: REGRESSION FAILED"                             | tee -a "${REPORT}"
    exit 1
else
    echo "  STATUS: REGRESSION PASSED"                             | tee -a "${REPORT}"
fi
