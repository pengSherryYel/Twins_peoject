# Code Description

## Main workflow codes
wf_qc_ass_ckv_bt.sh: Main workflow.
1. First do the quality check of raw reads use fastp.

2. Map clean reads to GPD database (bt2.sh). 

3. Then based on the mapping results calculate the relative abundance (TPM) (calculate_abundance.tpm.myscript.py).

## Dependent scripts
bt2.sh: Dependent script in main workflow. script for run bowtie2 index(GPD) and mapping.

calculate_abundance.tpm.myscript.py: Dependent script in main workflow. Script for calculating the relative abundance of viral
source from metagenomic data based on Bowtie2 output.



