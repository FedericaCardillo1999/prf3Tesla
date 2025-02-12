# cflaminar
Preprocessing pipeline for CF analysis across the cortical depth

[![Documentation Status] ADDLINK TO WEBPAGE

![plot]ADDFIGURE

## In active development
This package is still in development and its API might change. Documentation for this package can be found at [ADDLINK TO WEBPAGE] (not up to date)

## Preprocessing

## General steps:

### Bidsify the data:

-From scanner to BIDS, files should be renamed to be converted from PAR/REC to Nifti and bidsified. Renaming can be done using 'utils/rename_PAR4BIDS.sh':

```bash
cd '{MAIN_PATH}/utils'
source rename_PAR4BIDS.sh xxx
master -m 02a -s 001,002,xxx --lr #(long flag indicates PR direction of BOLD files; subjects separated with commas without spaces)
```
  Output:
  - Data and .json files acc. to BIDS

  Warning: check if fieldmaps have been correctly assigned to their respective bold files in their .json.

## Anatomical preprocessing:

### Create T1w MP2RAGE image (if necessary):
```bash
master -m 04 -s 001 #spinoza_qmrimaps: creates T1w image from 1st and 2nd inversion images using Pymp2rage
```
  Output:
  - derivatives/pymp2rage: T1w, T1wmap, brain mask (desc-spm_mask), copy of T2w

### Create sinus mask using T1w/T2w ratio:
i) Register anatomy to MNI space  
```bash
  master -m 05b -s 001 -j xxs (--sge --cmd) #spinoza_registration (anat-to-MNI) using ANTs. Matrix is necessary for sinus mask (-m 07).
```
Note: if using --sge --cmd to run in cluster, needs to re-run master -m 05b -s xxx upon completion to rename files.
  Outputs:
  - derivatives/ants: MNI-anat transf. matrix and MNI_2_T1w_Warped.

ii) Estimate sinus mask
```bash
  master -m 07 -s 001  #spinoza_registration (anat-to-MNI) using ANTs. Matrix is necessary for sinus mask (-m 07).
```
  Outputs:
  - derivatives/manual_masks: sinus mask (desc-mni_sinus)

### Denoise the T1w image to enhance WM/GM edges
```bash
  master -m 08 -s 001  
```
Outputs:
- derivatives/denoised: denoised T1w, T1map and copy? of desc-spm_mask

### Brain extraction and segmentation using CAT12
```bash
  master -m 09 -s 001  
```
Outputs:
- derivatives/cat12: catreport, and segmentations
- derivatives/manual_masks: cat_dura, cat_mask and copy of spm_mask (*cat_dura is the subtraction of cat_mask from spm_mask)
- derivatives/denoised: log and matlab script

### Final mask (combining previous masks) and masking
```bash
  master -m 13 -s 001  
```
Outputs:
- derivatives/manual_masks: desc-outside, desc-brainmask, desc-dura_dilated
- derivatives/masked_mp2rage: desc-masked_T1w
- derivatives/skullstripped: desc-skullstrip_T1w,-T1map

### Freesurfer segmentation - original resolution
```bash
  master -m 14 -s 001 (-j Ncores)   
```
Outputs:
- derivatives/freesurfer


## Functional preprocessing:

### Thermal denoising using NORDIC
```bash
  master -m 10 -s xxx --sge -q short.q
```
Outputs:
-~/sub-xxx/ses-1/func:
-~/sub-xxx/ses-1/no_nordic:

### FMRIPREP SDC
```bash
  master -m 15 -s xxx -t func -j 12 #version 23.2.1 - 6/March/2024
```
Outputs:


### Motion Correction using SPM
```bash
  qsub -V job_spmmoco.sh '[ProjectName]'
```
Outputs:
TODO: generate .nii.gz, remove (r)sub, copy to fmriprep/../../func 
      rename meansub file

### ROIs mask (based on the Benson atlas) to 
```bash
  qsub -V jobCFLup01_project_benson_ores.sh 001
```    
### Upsampling anat
```bash
  qsub -V jobCFLup02_upsampling_anat.sh 001
```
### Upsampling func
```bash
  qsub -V jobCFLup04_upsampling_func_nordicfirst.sh 001
```
### Upsampling boldref
```bash
  qsub -V jobCFLup05_upsampling_boldref_spmmoco.sh 001
```
### Coregistration
- Run once to create folder structure
- Create initial coreg matrix (manually, ITK-SNAP)
- Re-run to coregistrate anat2func

```bash
  qsub -V job_coreg_old_.sh 001
```
### Apply coregistration matrix to T1w, T2w

```bash
  qsub -V job_applyTransforms.sh 001
```

### Check and crop FOV
```bash
  code utils/vcode_cropping.ipynb
```
### Run Freesurfer on upsampled anatomy 
```bash
  qsub -V -pe smp 16 job_freesurferHires.sh 16 001
```
### Benson hires 
```bash
  conda activate mypy311 #environment where neuropythy is installed
  qsub -V job_project_benson_hires.sh 001
```

### Resampling GM
```bash
  qsub -V job_resamplingGM_nordicfirst.sh 001
```
### Fmriprep hires
```bash
  copy/move fmriprep low res to fmriprep ores
  Re-run fmriprep with hires anatomy obs: func can be the low res

```