#!/bin/bash

# ----------------------------------------------------------------------- #
#    Andes Virus Genomics Pipeline: Alignment -> Phylogeny -> Ancestry    #
# ----------------------------------------------------------------------- #
# Script uses MAFFT, IQ-TREE 3, and Treetime which must be pre-installed.

set -e # Exit immediately if any command fails

# -------------------------- GLOBAL VARIABLES --------------------------- # 
# Change these before running.

# Primary project working directory and fasta input
PROJECT_DIR="$HOME/dissertation"
DATA="$PROJECT_DIR/data/compare_andesense.fasta"
OUTDIR="$PROJECT_DIR/outputs/Segment_S_run_1"

# Reference files
NUCREF="$PROJECT_DIR/data/refdata/S_ref_nuc.fasta"
PROTREF="$PROJECT_DIR/data/refdata/S_ref_prot.fasta"

# Metadata and Phylogenetic settings
DATES_FILE="$PROJECT_DIR/data/dates.csv"
OUTGROUP="Outgroup_Taxon_Name" # Set specific outgroup accession #.

# Windows Destination
WIN_DEST="~/Files/"

# ------------------------ RUN_N DIRECTORY SETUP ------------------------ #
# Creates subdirectories for downstream processes.
ALIGNED_DIR="$OUTDIR/aligned"
TREES_DIR="$OUTDIR/trees"
ANCESTRY_DIR="$OUTDIR/ancestries"
MISC_DIR="$OUTDIR/misc"

echo "Setting up results directory under: $OUTDIR"
mkdir -p "$ALIGNED_DIR" "$TREES_DIR" "$ANCESTRY_DIR" "$MISC_DIR"

# Standardized file path mapping
BASENAME=$(basename "$DATA" .fasta)
ALIGNED_FASTA="$ALIGNED_DIR/al_${BASENAME}.fasta"
TREE_PREFIX="$MISC_DIR/iqtree_${BASENAME}"

# ---------------------------- MAFFT ALIGNMENT -------------------------- #
# Set for L-INS-i algorithm
echo "RUNNING MAFFT ALIGNMENT"
mafft --nuc \
      --add "$DATA" \
      --keeplength \
      --localpair \
      --maxiterate 1000 \
      "$NUCREF" > "$ALIGNED_FASTA"

echo "Alignment complete. Output saved to: $ALIGNED_FASTA"

# ------------------ IQ-TREE 3 PHYLOGENETIC INFERENCE ------------------- #
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
