#!/bin/bash

#$ -V
#$ -N WGBS_awemue
#$ -S /bin/bash
#$ -cwd
#$ -j y
#$ -b n
#$ -q all.q

eval "$(conda shell.bash hook)"
conda activate wgbs
nextflow run nextflow/methylseq/main.nf -profile conda -resume -params-file config/nf-params.json
conda deactivate