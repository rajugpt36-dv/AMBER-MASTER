#!/bin/bash
# clean.sh - Remove all UVM TB simulation artifacts
SIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "=== Cleaning ${SIM_DIR} ==="
rm -rf "${SIM_DIR}/xcelium.d" "${SIM_DIR}/coverage_db" "${SIM_DIR}/logs"
rm -rf "${SIM_DIR}/regress_results" "${SIM_DIR}/.simvision"
rm -f  "${SIM_DIR}"/waves.vcd "${SIM_DIR}"/waves.shm
rm -f  "${SIM_DIR}"/*.trn "${SIM_DIR}"/*.dsn "${SIM_DIR}"/*.key
rm -f  "${SIM_DIR}"/*.log "${SIM_DIR}"/xrun.history
echo "=== Clean done ==="
