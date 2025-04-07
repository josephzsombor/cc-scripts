#!/bin/bash

# Load required modules
echo "Loading required modules..."
module load StdEnv/2020 gcc/10.3.0 openmpi/4.1.1 orca/5.0.4

# Loop over all .out files in the directory
for file in *.out; do
    # Skip if no .out files are found
    [ -e "$file" ] || { echo "No .out files found."; exit 1; }

    basename="${file%.out}"
    absq_file="${basename}.out.absq.dat"

    if [ ! -e "$absq_file" ]; then
        echo "File not found: $absq_file ... Skipping."
        continue
    fi

    echo "Running orca_mapspc on $file ..."
    $EBROOTORCA/orca_mapspc "$file" ABSQ -eV -x02400 -x12500 -w0.75 -n5000
done

echo "All done!"
