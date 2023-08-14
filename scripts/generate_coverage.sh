#!/bin/bash

#$ -V
#$ -N WGBS_awemue
#$ -S /bin/bash
#$ -cwd
#$ -j y
#$ -b n
#$ -q all.q
#$ -t 1-27
#$ -pe smp 2

eval "$(conda shell.bash hook)"
conda activate wgbs

declare -a arrFiles
for file in $(basename -a results/bismark_methylation_calls/methylation_calls/*.txt.gz)
do
    arrFiles=("${arrFiles[@]}" "$file")
done

SGE_TASK_ID2=$(expr $SGE_TASK_ID - 1) 
SGE_TASK_ID3=$(echo $SGE_TASK_ID2| sed 's/^0*//')

if [[ "${arrFiles[SGE_TASK_ID3]}" == *"CpG_context"* ]];then

	cmd_bmk="bismark2bedGraph -buffer_size 10G --scaffolds --dir results/bismark_methylation_calls/methylation_calls -o ${arrFiles[SGE_TASK_ID3]}.cov.gz results/bismark_methylation_calls/methylation_calls/${arrFiles[SGE_TASK_ID3]}"
	echo ${cmd_bmk}
	echo
	eval ${cmd_bmk}
fi

if [[ "${arrFiles[SGE_TASK_ID3]}" == *"CHG_context"* ]];then

	cmd_bmk="bismark2bedGraph -buffer_size 20G --scaffolds --CX --dir results/bismark_methylation_calls/methylation_calls -o ${arrFiles[SGE_TASK_ID3]}.cov.gz results/bismark_methylation_calls/methylation_calls/${arrFiles[SGE_TASK_ID3]}"
	echo ${cmd_bmk}
	echo
	eval ${cmd_bmk}
fi

if [[ "${arrFiles[SGE_TASK_ID3]}" == *"CHH_context"* ]];then

	cmd_bmk="bismark2bedGraph -buffer_size 50G --scaffolds --CX --dir results/bismark_methylation_calls/methylation_calls -o ${arrFiles[SGE_TASK_ID3]}.cov.gz results/bismark_methylation_calls/methylation_calls/${arrFiles[SGE_TASK_ID3]}"
	echo ${cmd_bmk}
	echo
	eval ${cmd_bmk}
fi

mv -f results/bismark_methylation_calls/methylation_calls/${arrFiles[SGE_TASK_ID3]}.cov.gz results/bismark_methylation_calls/methylation_coverage
mv -f results/bismark_methylation_calls/methylation_calls/${arrFiles[SGE_TASK_ID3]}.cov.gz.bismark.cov.gz results/bismark_methylation_calls/methylation_coverage

conda deactivate
