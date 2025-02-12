#! /bin/sh
#$ -N spmMoCo
#$ -S /bin/sh
#$ -j y
#$ -q long.q
#$ -o /data1/projects/dumoulinlab/Lab_members/Mayra/projects/CFLamUp_beta/code/logs
#$ -u bittencourt
#$ -V


#Usage: qsub -V job_spmmoco.sh [Project_name]; will search for bold files in /Project/sub-xxx/func
module load matlab/R2021b

cd '/data1/projects/dumoulinlab/Lab_members/Mayra/programs/cflaminar/utils'
echo "Running spmMoCo on $1"
SPM_PATH=${SPM}

matlab -nodesktop -nodisplay -nosplash -r "main_spmmoco('$1')"


