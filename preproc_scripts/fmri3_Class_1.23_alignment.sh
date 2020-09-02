#!/bin/bash



### --- Notes
#
# 1) In this step we will calculate the rigid warp of the structural file
#		to the volreg base we made previously, and we will perform a
#		non-linear diffeomorphic warp to get the calculations to move
#		into template space.
#
# 2) We are not actually moving data into template space, just getting the
#		calculations to do so.
#
# 3) Your "brain" template need to be constructed before this script, as it
#		is needed in step 3 and 4. Step8 (a previous script) is what produced
#		this.
#
# 4) The warpings will take a few hours per participant, 10 should be plenty
#
# 5) This should be done for each participant, save step 3




### Step 1: Convert t1w struct file from nii to afni
#
# use 3dcopy



### Step 2: Calculate rigid alignment of t1w to epi volreg base
#
# - While this is rigid, we are still using an Local Pearson Correlation
# 		cost function for epi data (lpc+ZZ).
#
# - The lpc method uses negative correlations, aligning dark CSF in t1 images
# 		to bright CSF in epi images
#
# - This step will also skull-strip the data
#
# - Adjust the -anat and -epi arguments

align_epi_anat.py \
	-anat2epi \
	-anat TEST11+orig \
	-save_skullstrip \
	-suffix _al_junk \
	-epi epi_vr_base+orig \
	-epi_base 0 \
	-epi_strip 3dAutomask \
	-cost lpc+ZZ \
	-volreg off \
	-tshift off



### Step 3: convert your template to afni format, maintain coordinate information
#
# Do this for both your "head" and "brain" template
#
# This only needs to be done once, not for each participant

3dcopy <input>.nii.gz <output>+orig
3drefit -space MNI <output>+orig
3drefit -view tlrc <output>+orig



### Step 4: Calculate the non-linear diffeomorphic alignment of the t1w to the template
#
# Reference your brain template that was constructed on step8 and was converted above
#	This is the input for your -base option

auto_warp.py -base <template>+tlrc -input struct_ns+orig -skull_strip_input no

3dbucket -prefix struct_ns awpy/struct_ns.aw.nii*
cp awpy/anat.un.aff.Xat.1D .
cp awpy/anat.un.aff.qw_WARP.nii .
