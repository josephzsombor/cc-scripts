#!/bin/bash

# ============================================
# Script: run_orca_plot.sh
#
# Usage:
#   ./run_orca_plot.sh PLOT.txt START END BASENAME
#
# Description:
#   This script loads the required modules and runs $EBROOTORCA/orca_plot
#   on a series of NTO files named in the pattern:
#     BASENAME.sX.nto
#   where X is an integer from START to END (inclusive).
#
# Arguments:
#   1. PLOT.txt - The name of the input file used by orca_plot
#   2. START    - The starting number in the NTO file sequence
#   3. END      - The ending number in the NTO file sequence
#   4. BASENAME - The base filename (without the .sX.nto suffix)
#
# Example:
#   ./run_orca_plot.sh PLOT.txt 1 5 VOMnt-cpcm-tddft-1sulfur-hfx25.15-nto
#
#   This will run orca_plot on:
#     VOMnt-cpcm-tddft-1sulfur-hfx25.15-nto.s1.nto
#     VOMnt-cpcm-tddft-1sulfur-hfx25.15-nto.s2.nto
#     ...
#     VOMnt-cpcm-tddft-1sulfur-hfx25.15-nto.s5.nto
# ============================================

# Check if four arguments are provided
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 PLOT.txt START END BASENAME"
  exit 1
fi

PLOT_FILE=$1
START_NUM=$2
END_NUM=$3
BASENAME=$4

# Validate that START_NUM and END_NUM are integers and START_NUM <= END_NUM
if ! [[ "$START_NUM" =~ ^[0-9]+$ ]] || ! [[ "$END_NUM" =~ ^[0-9]+$ ]]; then
  echo "Error: START and END must be integers."
  exit 1
fi

if [ "$START_NUM" -gt "$END_NUM" ]; then
  echo "Error: START cannot be greater than END."
  exit 1
fi

# Load required modules
echo "Loading required modules..."
module load StdEnv/2020  gcc/10.3.0  openmpi/4.1.1  orca/5.0.4

# Loop through the sequence from START_NUM to END_NUM
for i in $(seq "$START_NUM" "$END_NUM"); do
  NTO_FILE="${BASENAME}.s${i}.nto"
  
  if [ ! -f "$NTO_FILE" ]; then
    echo "Warning: File '$NTO_FILE' not found. Skipping..."
    continue
  fi

  echo "Running orca_plot on $NTO_FILE with input $PLOT_FILE..."
  $EBROOTORCA/orca_plot "$NTO_FILE" -i < "$PLOT_FILE"

done

echo "All done!"

