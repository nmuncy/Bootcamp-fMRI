#!/bin/bash



### --- Notes
#
# This step will create an EPI-T1w intersection mask
#
# as well as a resampled template mask.




### Step 1: generate a mask of useful EPI data
#
# -union = only include voxels where data is found in all masks

# do this step for each run
3dAutomask -prefix tmp_mask.<run> <run>_volreg_clean+tlrc

# combine above into a single mask
3dmask_tool -inputs tmp_mask.*+tlrc.HEAD -union -prefix full_mask




### Step 2: generate a T1w (anatomy) mask
#
# first, resample T1w in template space
#
# then make a mask, dilate it
#
# -dilate_input = increase size of mask by x voxels
#		-5 = also erode x voxels
#
# -fill_holes - fill any holes, voxels surrounded by non-zero labels

3dresample -master full_mask+tlrc -input struct_ns+tlrc -prefix tmp_anat_resamp
3dmask_tool -dilate_input 5 -5 -fill_holes -input tmp_anat_resamp+tlrc -prefix final_anat_mask




### Step 3: generate intersection mask
#
# alse record difference of full_mask and final_anat_mask
#
# -inter = include a voxel in either mask
#
# -no_automask = don't generate a brain mask
#
# "| tee foo.txt" = a way to save stdout to a file

3dmask_tool -input full_mask+tlrc final_anat_mask+tlrc -inter -prefix mask_epi_anat
3dABoverlap -no_automask full_mask+tlrc final_anat_mask+tlrc | tee out.mask_ae_overlap.txt




### Step 4: generate template mask for participant

3dresample -master full_mask+tlrc -prefix ./tmp_resam_group -input </path/to/template+tlrc>
3dmask_tool -dilate_input 5 -5 -fill_holes -input tmp_resam_group+tlrc -prefix Template_mask
