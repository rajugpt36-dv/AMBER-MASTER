@echo off
setlocal enabledelayedexpansion

echo === Merging Coverage Databases ===
dir /b /s coverage_db\*.ucdb > ucdb_list.txt
vcover merge coverage_db\merged_coverage.ucdb -f ucdb_list.txt

echo === Generating Merged HTML Report ===
vcover report -html coverage_db\merged_coverage.ucdb -htmldir merged_covhtmlreport -details
