#!/bin/bash

# ----------------------------------------------------------------------- #
#     Andes Virus Genomics Pipeline: Alignment -> Phylogeny -> Ancestry    #
# ----------------------------------------------------------------------- #
# Script uses MAFFT, IQ-TREE 3, and Treetime which must be pre-installed.

set -e # Exit immediately if any step fails

# -------------------------- GLOBAL VARIABLES --------------------------- # 
# Change these before running.

# Primary project working directory and fasta input
PROJECT_DIR="$HOME/dissertation"
DATA="$PROJECT_DIR/data/final/ANDV_M/ANDV_M.fasta"
OUTDIR="$PROJECT_DIR/ANDV-genomics-dissertation/Segment_M_run_1"

# Reference files
NUCREF="$PROJECT_DIR/data/refdata/M_ref_nuc.fasta"
PROTREF="$PROJECT_DIR/data/refdata/M_ref_prot.fasta"

# Metadata and Phylogenetic settings
DATES_FILE="$PROJECT_DIR/data/dates_ANDV_M.csv"
OUTGROUP="OR987856.1" # Set specific outgroup accession #.

# Windows Destination
WIN_DEST="/mnt/c/Users/zhiva/Files/Bioinformatics/UoG/diss"

# ----------------------- STEP CONTROL CONFIGURATION ------------------- #
# Default: Run the full pipeline
STOP_AFTER="all"

while getopts "aph" opt; do
  case $opt in
    a ) STOP_AFTER="alignment" ;;
    p ) STOP_AFTER="phylogeny" ;;
    h )
      echo "To use script: pipeline.sh [-a |-p |__]"
      echo " -a      : Stop after MAFFT Alignment"
      echo " -p      : Stop after IQ-TREE 3 Phylogeny"
      echo " [blank] : Run complete pipeline"
      exit 0
      ;;
    \? )
      echo "Invalid option. Use -h for help."
      exit 1
      ;;
  esac
done

# ------------------------ RUN_N DIRECTORY SETUP ------------------------ #
# Creates subdirectories for downstream processes.
ALIGNED_DIR="$OUTDIR/aligned"
TREES_DIR="$OUTDIR/trees"
ANCESTRY_DIR="$OUTDIR/ancestries"
MISC_DIR="$OUTDIR/misc"

# Check if directory exists before writing.
if [ -d "$OUTDIR" ]; then
  echo "Output directory already exists: $OUTDIR"
  echo "Rename or remove $OUTDIR or change before re-running."
  exit 1
fi

# Creates directory for run.
echo "Setting up results directory under: $OUTDIR"
mkdir -p "$ALIGNED_DIR" "$TREES_DIR" "$ANCESTRY_DIR" "$MISC_DIR"

# Standardized file path mapping
BASENAME=$(basename "$DATA" .fasta)
ALIGNED_FASTA="$ALIGNED_DIR/al_${BASENAME}.fasta"
TREE_PREFIX="$MISC_DIR/iqtree_${BASENAME}"

# ---------------------------- MAFFT ALIGNMENT -------------------------- #
# Set for L-INS-i algorithm.
echo "RUNNING MAFFT ALIGNMENT"
mafft --nuc \
      --add "$DATA" \
      --keeplength \
      --localpair \
      --maxiterate 1000 \
      "$NUCREF" > "$ALIGNED_FASTA"

echo "Alignment complete. Output saved to: $ALIGNED_FASTA"

# Stop option after alignment
if [ "$STOP_AFTER" = "alignment" ]; then
    echo "STOPPING AFTER ALIGNMENT"
    echo "EXPORTING RESULTS TO WINDOWS"
    mkdir -p "$WIN_DEST"
    cp -r "$OUTDIR" "$WIN_DEST/"
    exit 0
fi

# ------------------ IQ-TREE 3 PHYLOGENETIC INFERENCE ------------------- #
# Constructs phylogeny. Outgroup can be modified in global variables.
echo "RUNNING IQ-TREE 3 PHYLOGENY"
iqtree3 -s "$ALIGNED_FASTA" \
        --prefix "$TREE_PREFIX" \
        -m MFP \
        -B 1000 \
        -o "$OUTGROUP" \
        -T AUTO

# Port key tree files into the 'trees/' subdirectory
cp "${TREE_PREFIX}.treefile" "$TREES_DIR/"
cp "${TREE_PREFIX}.contree"  "$TREES_DIR/"
cp "${TREE_PREFIX}.iqtree"   "$TREES_DIR/"

FINAL_TREEFILE="$TREES_DIR/$(basename "${TREE_PREFIX}.treefile")"
echo "PHYLOGENY COMPLETE. CORE TREE FILES PORTED TO: $TREES_DIR"

# Stop option after phylogeny
if [ "$STOP_AFTER" = "phylogeny" ]; then
    echo "STOPPING AFTER PHYLOGENY"
    echo "EXPORTING RESULTS TO WINDOWS"
    mkdir -p "$WIN_DEST"
    cp -r "$OUTDIR" "$WIN_DEST/"
    exit 0
fi

# ------------------ TREETIME ANCESTRAL RECONSTRUCTION ------------------ #
echo "RUNNING TREE TIME ANCESTRAL RECONSTRUCTION"
treetime --aln "$ALIGNED_FASTA" \
         --tree "$FINAL_TREEFILE" \
         --dates "$DATES_FILE" \
         --outdir "$ANCESTRY_DIR"

# ----------------------- EXPORT DATA TO WINDOWS ------------------------ #
echo "EXPORTING RESULTS TO WINDOWS"

mkdir -p "$WIN_DEST"
cp -r "$OUTDIR" "$WIN_DEST/"

echo "PIPELINE COMPLETE"
echo "All outputs successfully written to $OUTDIR and exported to $WIN_DEST"