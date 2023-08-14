# nf-core Nextflow methylseq pipeline (v1.6.1)

## Before starting

#### 1. Install conda
Ensure that conda is installed on your account on the biocluster.

    conda -V

If you don't known what conda is or if it is not installed, see [our page about conda](https://gccode.ssc-spc.gc.ca/ac_/general/-/tree/master/conda).

This wgbs analysis is meant to be used on the biocluster. However, the interactive mode is not recommended.  This tutorial includes ready-to-use qsub commands to submit scripts in batch mode. Please use qlogin before proceeding.

#### 2. Use git to clone the wgbs repository
Clone all necessary files in the directory of your choice with:

    git clone https://gccode.ssc-spc.gc.ca/ac_/eia/wgbs.git

This command creates a directory named wgbs in which you will execute the pipeline. It is always a good practice to be at the top directory of your project to execute scripts. 


## Installation of wgbs environment and nextflow methylseq pipeline

#### 1. To install the conda wgbs environment, use the following commands:
This wgbs environment contains nextflow, R and bismark.
```shell
# Create a conda environment with:
conda env create -n wgbs
conda activate wgbs 
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda install nextflow
conda install -c bioconda bismark
conda install r-base
conda deactivate
```

#### 2. To install methylseq pipeline
This procedure installs a local copy of the pipeline in your project folder. The latest version available was 1.6.1 at the time of writing this procedure. Using a local copy allows modifications to somes scripts. To download and install the pipeline, use the following commands:  
```shell
#make sure you are in your base project folder
cd nextflow/methylseq
conda activate wgbs
nextflow clone nf-core/methylseq -r v1.6.1 .
conda deactivate
```

#### 3. Replace nextflow.config, base.config and main.nf with modified versions

- nextflow.config must be modified to support the biocluster.
  here is a list a all modifications made:

  1.   line 8 (added):   process.executor = 'sge'  (add supprt to the Sun Grid Engine (SGE))
  1.   line 9 (added):   process.penv = 'smp'      (add supprt to the Sun Grid Engine (SGE))
  1.   line 159 (added): // Increase time available to build conda environment
  1.   line 160 (added): conda { createTimeout = "60 min" }


- base.config has been modified to increase the Preseq time to process bam files. Here's the code:
  ```shell
  }
    withName:preseq {
      errorStrategy = 'ignore'
    }
  ```
  to 
  ```shell
  }
    withName:preseq {
      cpus = { check_max( 2 * task.attempt, 'cpus') }
      memory = { check_max( 64.GB * task.attempt, 'memory') }
      time = { check_max( 6.h * task.attempt, 'time') }
    }
  ```
- main.nf has been modified to removed reads with quality lower than 30 and to output all methylation contexts
  ```shell
  }
          if( params.single_end ) {
              """
              trim_galore --fastqc --gzip $reads \
                $rrbs $c_r1 $tpc_r1 --cores $cores -q 30
              """
          } else {
              """
              trim_galore --fastqc --gzip --paired $reads \
                $rrbs $c_r1 $c_r2 $tpc_r1 $tpc_r2 --cores $cores -q 30
              """
          }
  ```
  and line 608 (flag '--merge_non_CpG' removed): 
  ```
  comprehensive = params.comprehensive ? '--comprehensive' : ''
  ```

To Replace nextflow.config and base.config:

  ```shell
  # Make sure you are in your base project folder
  cp -f config/nextflow.config nexflow/methylseq
  cp -f config/base.config nextflow/methylseq/conf
  cp -f config/main.nf nextflow/methylseq
  ```

#### 4. Edit pipeline settings
The file nf-params.json in the config folder contains all the parameters to run the pipeline.
An online tool, available at https://nf-co.re/methylseq/usage, can be used to help generate this file.
For this project, only the input parameter must be modified to reflect the path of raw sequences.

```
{
    "input": ".\/path_3\/*_R{1,2}.fastq.gz",
    "fasta": "GCF_002263795.1_ARS-UCD1.2_genomic.fa",
    "comprehensive": true,
    "em_seq": true
}
```


## Nextflow analysis

 #### 1. Make your fasta sequences ready
It is considered good practice to use symbolic links instead of the fasta files themselves. Symbolic links can be created in the folder of your choice with this simple command:
```
ln -s path/to/fasta/file_R1.fastq.gz path/to/destination/file_R1.fastq.gz
```
Once the links are created, you can rename them according to this format: XXXXXXX_R1.fastq.gz
Make sure your links are in the input directory chosen in "step 4: Edit pipeline settings".

 #### 2. Execute Nextflow
This bash script launch_nextflow.sh runs the pipeline. Results are placed in the results directory.  

```shell
#Make sure you are in your base project folder before executing the qsub command.
qsub -cwd ./scripts/launch_nextflow.sh

# you should get a message like this one:
# Your job XXXXXXXX ("WGBS_awemue") has been submitted

# Use qstat to monitor your job. Once the job is done, it should no longer appear in qstat.
# Depending on the number of fastas, the script should take several hours/days to complete. 
```
 #### 3. Produce coverage files for methylkit package
By default, biskmark makes a CpG methylation coverage file for each sample. This script adds CHG and CHH coverage files for each samples. Run this script once the pipeline has successfully finished.
```shell
#Make sure you are in your base project folder before executing the qsub command.
qsub -cwd ./scripts/generate_coverage.sh
```

#### 4. Software versions of methylseq

```
nf-core/methylseq	v1.6.1
Nextflow  v20.10.0
Bismark genomePrep	v0.23.0
FastQC	v0.11.9
Cutadapt	v3.5
Trim Galore!	v0.6.6
Bismark	v0.23.0
Bismark Deduplication	v0.23.0
Bismark methXtract	v0.23.0
Bismark Report	v0.23.0
Bismark Summary	v0.22.4
Samtools	v1.11
BWA	v0.7.17-r1188
bwa-meth	v0.2.2
Picard MarkDuplicates	v2.25.4
MethylDackel	v0.5.2 (using HTSlib version 1.11)
Qualimap	v2.2.2-dev
Preseq	v2.0.3
MultiQC	v1.10.1
HISAT2	v2.2.1
```

