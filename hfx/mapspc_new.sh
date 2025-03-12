#!/bin/bash

# ============================================
# Script: run_mapspc.sh
#
# Usage:
#   ./run_mapspc.sh BASENAME
#
# Description:
#   This script loads the required modules and runs orca_mapspc
#   on all available ABSQ files generated from ORCA calculations.
#   It looks for files with the naming pattern:
#     BASENAME<HFX>.out.absq.dat
#
#   If the file exists, orca_mapspc is executed on:
#     BASENAME<HFX>.out ABSQ -eV -x02400 -x12500 -w0.75 -n5000
#
# Arguments:
#   BASENAME    The base name of the files (excluding %HFX values and extensions)
#
# Example:
#   ./run_mapspc.sh VODtsq-cpcm-tddft-4sulfur-hfx
#
# ============================================

# Function to print usage and exit
usage() {
  echo "Usage:"
  echo "  $0 BASENAME"
  echo
  echo "Arguments:"
  echo "  BASENAME    The common prefix of the output files (without %HFX and extensions)"
  echo
  echo "Example:"
  echo "  $0 VODtsq-cpcm-tddft-4sulfur-hfx"
  echo "    → Processes files like calculation-hfx0.0.out.absq.dat, etc."
  echo
  exit 1
}

# Check if basename was provided
if [ "$#" -ne 1 ]; then
  usage
fi

basename="$1"

# Load required modules
echo "Loading required modules..."
module load StdEnv/2020 gcc/10.3.0 openmpi/4.1.1 orca/5.0.4

# Loop over HFX values (0.0 to 60.0 with step 1.0)
for i in $(seq 0.0 1.0 60.0); do
    absq_file="${basename}${i}.out.absq.dat"

    if [ ! -e "$absq_file" ]; then
        echo "File not found: $absq_file ... Skipping."
        continue
    fi

    echo "Running orca_mapspc on ${basename}${i}.out ..."
    $EBROOTORCA/orca_mapspc "${basename}${i}.out" ABSQ -eV -x02400 -x12500 -w0.75 -n5000
done

echo "All done!"

