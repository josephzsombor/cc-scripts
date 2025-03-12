#!/bin/bash

# ============================================
# Script: run_orca_plot.sh
#
# Usage:
#   ./run_orca_plot.sh (-tddft | -rocis) PLOT.txt START END BASENAME
#
# Description:
#   This script loads the required modules and runs $EBROOTORCA/orca_plot
#   on a series of NTO files named in one of the following patterns:
#
#     BASENAME.sX.nto  (for TD-DFT calculations with the -tddft flag)
#     BASENAME.X.nto   (for ROCIS/DFT calculations with the -rocis flag)
#
# Arguments:
#   -tddft      Flag to indicate TD-DFT calculation file pattern (BASENAME.sX.nto)
#   -rocis      Flag to indicate ROCIS/DFT calculation file pattern (BASENAME.X.nto)
#   PLOT.txt    The name of the input file used by orca_plot
#   START       The starting number in the NTO file sequence
#   END         The ending number in the NTO file sequence
#   BASENAME    The base filename (without the .sX.nto or .X.nto suffix)
#
# Examples:
#   ./run_orca_plot.sh -tddft PLOT.txt 1 5 calculation
#     → Runs orca_plot on:
#         calculation.s1.nto
#         calculation.s2.nto
#         ...
#         calculation.s5.nto
#
#   ./run_orca_plot.sh -rocis PLOT.txt 1 5 calculation
#     → Runs orca_plot on:
#         calculation.1.nto
#         calculation.2.nto
#         ...
#         calculation.5.nto
#
# ============================================

# Function to print usage and exit
usage() {
  echo "Usage:"
  echo "  $0 (-tddft | -rocis) PLOT.txt START END BASENAME"
  echo
  echo "Flags:"
  echo "  -tddft      Use TD-DFT file naming (BASENAME.sX.nto)"
  echo "  -rocis      Use ROCIS/DFT file naming (BASENAME.X.nto)"
  echo
  echo "Arguments:"
  echo "  PLOT.txt    Input file for orca_plot"
  echo "  START       Starting number in NTO file sequence"
  echo "  END         Ending number in NTO file sequence"
  echo "  BASENAME    Base filename for the NTO files"
  echo
  echo "Examples:"
  echo "  $0 -tddft PLOT.txt 1 5 calculation"
  echo "    → Runs orca_plot on calculation.s1.nto ... calculation.s5.nto"
  echo
  echo "  $0 -rocis PLOT.txt 1 5 calculation"
  echo "    → Runs orca_plot on calculation.1.nto ... calculation.5.nto"
  echo
  exit 1
}

# Check at least 5 arguments provided
if [ "$#" -lt 5 ]; then
  usage
fi

# Parse flags
case "$1" in
  -tddft)
    mode="tddft"
    ;;
  -rocis)
    mode="rocis"
    ;;
  *)
    echo "Error: First argument must be -tddft or -rocis"
    usage
    ;;
esac

# Shift past the mode flag
shift

# Collect arguments
PLOT_FILE=$1
START_NUM=$2
END_NUM=$3
BASENAME=$4

# Validate start/end numbers
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
module load StdEnv/2020 gcc/10.3.0 openmpi/4.1.1 orca/5.0.4

# Loop through the files and run orca_plot
for i in $(seq "$START_NUM" "$END_NUM"); do
  if [ "$mode" == "tddft" ]; then
    NTO_FILE="${BASENAME}.s${i}.nto"
  else
    NTO_FILE="${BASENAME}.${i}.nto"
  fi

  if [ ! -f "$NTO_FILE" ]; then
    echo "Warning: File '$NTO_FILE' not found. Skipping..."
    continue
  fi

  echo "Running orca_plot on $NTO_FILE with input $PLOT_FILE..."
  $EBROOTORCA/orca_plot "$NTO_FILE" -i < "$PLOT_FILE"

done

echo "All done!"

