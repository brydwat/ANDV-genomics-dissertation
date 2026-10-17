# Andes Virus Genomics Alignment-Phylo-Ancestry Pipeline

An automated Bash workflow for sequential sequence alignment, phylogenetic tree reconstruction, and ancestral sequence inference. These three scripts together were developed for my dissertation, which I did with advising from David Robertson and Kieran Lamb at the University of Glasgow. The output from this short pipeline (plus slicing/translation) formed the core scripts I used for evaluating data over dozens of runs of different MSA groups while investigating patterns in ANDV genomics. I have unified them here so that I have no more headaches with mixed and matched variables/file/folder names in the future. 

Previously running through this script involved manually changing the variables for each individual script on each run. A single typo or forgetting to change the reference led to errors, messy data outputs, cluttered directories, etc. Now as I develop my dissertation into a manuscript, I want to avoid those headaches in the future. Its not fully automated and optioned with the full pipeline of analysis I conducted. I may do this later simply as an excercise in python with argparse. But, simply grouping the modifiable variables at the top as global variables and connecting the scripts into a streamlined workflow makes it much easier to manage outputs. Altogether that is probably 95% of the code I ran for my dissertation by number of script calls so consolidating these scritps could have been a significant time saver.

## Overview

This pipeline unifies three core analysis steps into a single executable workflow:
**1) Sequence Alignment:** MAFFT (L-INS-i model is set by default)
**2) Phylogenetic Reconstruction:** IQ-TREE 3 (ModelFinder + Ultrafast Bootstrap)
**3) Ancestral Sequence Inference:** TreeTime (time-scaled ancestral node reconstruction)

All outputs are automatically structured into subdirectories for reproducibility and downstream export.

Added two options -s align which stops after alignment, and s -phylo which stops after phylogeny. No argument runs full script.
Example: ANDV_pipeline.sh [-a |-p |__].

---

## Directory Structure

Running the pipeline automatically a directory output folder with the structure below:


Segment_Run_Directory/
-> aligned/
-> trees/
-> ancestries/
-> misc/

## Prerequisites

The following bioinformatic packages are required in system $PATH:
 - MAFFT
 - IQ-TREE 3
 - TreeTime
