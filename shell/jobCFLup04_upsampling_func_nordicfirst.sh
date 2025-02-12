#! /bin/sh
#$ -N ups_func
#$ -S /bin/sh
#$ -j y
#$ -q short.q
#$ -o /data1/projects/dumoulinlab/Lab_members/Mayra/projects/CFLamUp/code/logs
#$ -u bittencourt

# Load modules
module load afni

# Usage: source upsampling.sh xxx / qsub -V script.sh xxx
# Upsamples Nifti files

subject=sub-$1
session=1

OLDPWD=${PWD}
PROJ_DIR=/data1/projects/dumoulinlab/Lab_members/Mayra/projects/CFLamUp
cd $PROJ_DIR

# Fmriprep - No NORDIC, No Pybest
# Upsampling nifti and copying json files from original bids folder to derivatives/upsampling


for denoising in nordic
do

  UP_DIR=$PROJ_DIR/derivatives/upsampling/${subject}/ses-${session}/func/${denoising}
  if [[ ! -d $UP_DIR ]]; then
    echo "Creating $UP_DIR  folder"
    mkdir -p $UP_DIR
  else
    echo "$UP_DIR  folder already exists."
  fi

  for suffix in ret_run-1 ret_run-2 ret_run-3 ret_run-4
  do
    if [[ ${denoising} == "nordic" ]]; then
    NII_DIR=$PROJ_DIR/derivatives/fmriprep/${subject}/ses-${session}/func
    filename=${subject}_ses-${session}_task-${suffix}_desc-preproc_bold
    # elif [[ ${denoising} == "nordic" ]]; then
    # NII_DIR=$PROJ_DIR/${subject}/ses-1/func
    # filename=${subject}_ses-${session}_task-${suffix}_desc-nordic_bold
    # elif [[ ${denoising} == "no_preproc" ]]; then
    # NII_DIR=$PROJ_DIR/${subject}/ses-${session}/orig
    # filename=${subject}_ses-${session}_task-${suffix}_bold
    fi
    if [[ ! -f ${UP_DIR}/${filename}.nii.gz ]]; then
    3dresample -dxyz 0.4 0.4 0.4 -rmode Cubic -prefix ${UP_DIR}/${filename}.nii.gz -input ${NII_DIR}/${filename}.nii.gz
    # Backing up and replacing files with original resolution by upsampled files
    if [[ ! -f ${UP_DIR}/${filename}_ores.nii.gz ]]; then
      cp ${NII_DIR}/${filename}.nii.gz ${UP_DIR}/${filename}_ores.nii.gz
    else
      echo "backup of original resolution ${suffix} file already exists"
    fi
    fi
  done
done

cd ${OLDPWD}
