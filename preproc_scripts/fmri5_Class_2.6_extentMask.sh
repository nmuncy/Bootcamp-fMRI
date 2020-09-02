#!/bin/bash



### --- Notes
#
# 1) Steps 1-3, 6 are done for each run (11, 12)
#
# 2) point = make a mask, remove bad volumes




### Step 1 - create mask for each run
#
# each voxel with a value with be included into a binar mask

3dcalc -overwrite -a <run+orig> -expr 1 -prefix tmp_<run>_mask




### Step 2 - warp mask into template space
#
# same as before - line up runs. make sure to determine voxel size
#
# interp = interpolation mode
#
# ainterp = interpolation for binary files

3dNwarpApply -master struct_ns+tlrc \
	-dxyz <$gridSize> \
	-source tmp_<run>_mask+orig \
	-nwarp "anat.un.aff.qw_WARP.nii mat.<run>.warp.aff12.1D" \
	-interp cubic \
	-ainterp NN -quiet \
	-prefix tmp_<run>_mask_warped




### Step 3 - compute minimum of input voxels, extract it
#
# -min = compute minimum of input voxels

3dTstat -min -prefix tmp_<run>_min tmp_<run>_mask_warped+tlrc




### Step 4 - combine runs of phase (Phase = Test, runs = 11, 12) into a single file
#
# -datum = sets type of datum for output

3dMean -datum short -prefix tmp_mean_<phase> tmp_TEST1?_min+tlrc.HEAD




### Step 5 - threshold combined file to construct a binary mask. This is the extension mask
#
# 'step(a-0.999)' = anything greater than 0.999 call 1 (afni has weird syntax)

3dcalc -a tmp_mean_<phase>+tlrc -expr 'step(a-0.999)' -prefix <phase>_epiExt_mask




### Step 6 - use extension mask to remove data from warped EPI data
#
# essentially matrix multiplication

3dcalc -a tmp_<run>_nomask+tlrc -b <phase>_epiExt_mask+tlrc -expr 'a*b' -prefix <run>_volreg_clean
