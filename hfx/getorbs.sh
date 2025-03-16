#!/bin/bash

# Usage description
usage() {
    echo "Usage: $0 [-hfx] <basename>"
    echo
    echo "Extracts orbital energies from output files."
    echo
    echo "Arguments:"
    echo "  -hfx        Enable HFX mode. Loops over %HFX values from 0.0 to 60.0 (step 1.0)."
    echo "              Looks for files with the pattern <basename><HFX>.out"
    echo
    echo "  basename    The base name of the output files (excluding %HFX values or .out extensions)."
    echo
    echo "Output CSV format:"
    echo "  -hfx mode   %HFX,Spin,NO,OCC,E(Eh),E(eV)"
    echo "  no -hfx     Spin,NO,OCC,E(Eh),E(eV)"
    echo "  Spin: 0 = up, 1 = down"
    echo
    echo "Examples:"
    echo "  $0 -hfx calculation-hfx    # loops over HFX values and extracts"
    echo "  $0 calculation             # extracts from a single output file"
    echo
    exit 1
}

# Defaults
hfx_mode=0

# Parse options
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
    case $1 in
        -hfx )
            hfx_mode=1
            ;;
        * )
            usage
            ;;
    esac
    shift
done

# Shift past '--' if present
if [[ "$1" == '--' ]]; then shift; fi

# Get the basename
basename="$1"

# Check if basename was provided
if [[ -z "$basename" ]]; then
    usage
fi

#Define output CSV file based on mode
if [[ $hfx_mode -eq 1 ]]; then
    csvfile="${basename}_orbital_energies.csv"
    echo "%HFX,Spin,NO,OCC,E(Eh),E(eV)" > "$csvfile"
else
    csvfile="${basename}_orbital_energies.csv"
    echo "Spin,NO,OCC,E(Eh),E(eV)" > "$csvfile"
fi

# Function to extract orbital data from a file
extract_orbitals() {
    local file="$1"
    local hfx_value="$2"

    awk -v hfx="$hfx_value" -v hfx_mode="$hfx_mode" '
        BEGIN { spin=""; spin_code=""; capture=0 }
        /ORBITAL ENERGIES/ { capture=1; next }
        /SPIN UP ORBITALS/ { spin="up"; spin_code=0; next }
        /SPIN DOWN ORBITALS/ { spin="down"; spin_code=1; next }
        /MOLECULAR ORBITALS/ { exit }
        capture && NF >= 4 {
            no=$1; occ=$2; e_eh=$3; e_ev=$4;
            if (no ~ /^[0-9]+$/ && occ ~ /^[0-9.]+$/ && e_eh ~ /^-?[0-9.]+$/ && e_ev ~ /^-?[0-9.]+$/) {
                if (hfx_mode == 1)
                    print hfx "," spin_code "," no "," occ "," e_eh "," e_ev
                else
                    print spin_code "," no "," occ "," e_eh "," e_ev
            }
        }
    ' "$file" >> "$csvfile"
}

# Main logic depending on hfx_mode
if [[ $hfx_mode -eq 1 ]]; then
    for i in $(seq 0 1.0 60.0); do
        file="${basename}${i}.out"

        if [[ -f "$file" ]]; then
            echo "Processing $file..."
            extract_orbitals "$file" "$i"
        else
            echo "Warning: File $file not found" >&2
        fi
    done
else
    file="${basename}.out"

    if [[ -f "$file" ]]; then
        echo "Processing $file..."
        extract_orbitals "$file"
    else
        echo "Error: File $file not found" >&2
        exit 1
    fi
fi

echo "Extraction complete. Data saved to $csvfile."

