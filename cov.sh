#!/bin/bash
# =============================================================================
# File    : cov.sh
# Usage   : ./cov.sh
# Merges all per-test coverage DBs, generates HTML report via IMC
# =============================================================================
set -e
SIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COV_DIR="${SIM_DIR}/coverage_db"
MERGE_DIR="${SIM_DIR}/coverage_merged"
LOG_DIR="${SIM_DIR}/logs"
mkdir -p "${MERGE_DIR}" "${LOG_DIR}"

echo "=== Scanning for coverage databases in ${COV_DIR} ==="
COV_INPUTS=""
for d in "${COV_DIR}"/*/; do
    if [ -d "${d}" ]; then
        COV_INPUTS="${COV_INPUTS} ${d}"
        echo "  Found: ${d}"
    fi
done

if [ -z "${COV_INPUTS}" ]; then
    echo "[ERROR] No coverage databases found. Run 'make regress' first."
    exit 1
fi

echo "=== Merging coverage databases ==="
imc -load ${COV_INPUTS} \
    -store "${MERGE_DIR}" \
    -log "${LOG_DIR}/imc_merge.log"

echo "=== Generating HTML coverage report ==="
imc -load "${MERGE_DIR}" \
    -execcmd "report -detail -html -out ${MERGE_DIR}/cov_report" \
    -log "${LOG_DIR}/imc_report.log"

echo ""
echo "============================================================"
echo "  Merged DB  : ${MERGE_DIR}"
echo "  HTML Report: ${MERGE_DIR}/cov_report/index.html"
echo "============================================================"

# Print text summary
echo "=== Text Summary ==="
imc -load "${MERGE_DIR}" \
    -execcmd "report -summary" \
    -log /dev/null 2>&1 | grep -E "Coverage|Total|Covered|Percent|%"
