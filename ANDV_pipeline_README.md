# Andes Virus Genomics Alignment-Phylo-Ancestry Pipeline

An automated Bash workflow for sequential sequence alignment, phylogenetic tree reconstruction, and ancestral sequence inference. These three scripts together were developed for my dissertation with David Robertson and Kieran Lamb at the University of Glasgow and formed the core scripts I used for evaluating data over dozens of runs of different MSA groups. I have unified them here so that I have no more headaches with mixed and matched variables/file/folder names in the future. Previously running through this script involved manually changing the variables for each individual script on each run. A single typo or forgetting to change the reference led to errors, messy data outputs, cluttered directories, etc. Now as I develop my dissertation into a manuscript, I want to avoid those headaches in the future. Its not fully automated and optioned which I would implement in python with argparse and may do later simply as an excercise. But simply grouping the modifiable variables at the top and stringing the scripts together one after the other makes it much more streamlined. I also may add the IQ-TREE 3 ancestral sequence reconstruction script as an option and I may add the sequence translation and ANDV segment protein slicing script I developed in python. Altogether that is probably 95% of the code I ran for my dissertation by number of script calls.

## Overview

This pipeline unifies three core analysis steps into a single executable workflow:
**1) Sequence Alignment:** MAFFT (`--add` mode with seed reference sequence)
**2) Phylogenetic Reconstruction:** IQ-TREE 3 (ModelFinder + Ultrafast Bootstrap)
**3) Ancestral Sequence Inference:** TreeTime (time-scaled ancestral node reconstruction)

All outputs are automatically structured into subdirectories for reproducibility and downstream export.

---

## Directory Structure

Running the pipeline automatically a directory output folder with the structure below:


Segment_Run_Directory/
 > aligned/
 > trees/
 > ancestries/
 > misc/

## Prerequisites

The following bioinformatic packages are required in system $PATH:
 - MAFFT
 - IQ-TREE 3
 - TreeTime
