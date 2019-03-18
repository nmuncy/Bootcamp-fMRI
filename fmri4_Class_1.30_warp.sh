#!/bin/bash



### --- Notes
#
# 1) In this script, we create master warp files by concatenating several
#		warp matrices. This will be used to move EPI data into template space.
#
#		This includes the matrices for
#			a) aligning each volume to volreg base
#			b) the rigid alignment of the T1w scan with volreg base, and
#			c) the non-linear normalization of the T1w into template space
#
# 2) Output from align_epi_anat.py and auto_warp.py (from the previous script)
#		will be used in some of these calculations.
#
# 3) Then we will warp data into template space
#		This step will take a bit of time




### Step 1 - calculate the warp of each volume to the volreg base
#
# - This will have to be done for each run in the experiment
#
# - options:
#
# 		-zpad = zeropad around the edges by n voxels during rotations
#			constrains rotation to voxels associated with tissue
#
# 		-base = volreg base, previously constructed
#
# 		-1D* = save warp calculations in output files that will be used downstream
#
# 		-cubic = use cubic polynomial interpolation

for i in 1 2; do
	3dvolreg \
	-verbose \
	-zpad 1 \
	-base epi_vr_base+orig \
	-1Dfile dfile.TEST1$i.1D \
	-prefix TEST1$i_volreg \
	-cubic \
	-1Dmatrix_save mat.TEST1$i.vr.aff12.1D \
	TEST1$i+orig
done


### Step 2 - concatenate warp calculations to move EPI data to template space
#
# - This will combine all the warping into a single file.
#
# - We need the volreg, alignment, and non-linear calcs for this file
#		The order is important!
#
# - input:
#
#		anat.un.aff.Xat.1d = the non-linear diffeomorphic calculations
#
#		struct_al_junk_mat.aff12.1D = the rigid alignment of the T1w to volreg base
#
#		-I = invert matrix (for the struct_al_junk*)
#
#		mat.<run>.vr.aff12.1D = the volume registration calculation (from 3dvolreg)
#
#		mat.<run>.warp.aff12.1d = output warp calculations

cat_matvec -ONELINE \
anat.un.aff.Xat.1D \
struct_al_junk_mat.aff12.1D -I \
mat.<run>.vr.aff12.1D > mat.<run>.warp.aff12.1D




### Step 3 - warp EPI data into template space
#
# - first, determine the size of voxels via "3dinfo -di""
#
# - options:
#
#		-master = reference dataset in template space (T1w)
#
#		-dxyz = voxel dimensions
#
#		-source = EPI data to be warped
#
#		-nwarp = warp matrix, two files are input
#			the first is the warp matrix produced in previous script
#			the other is the warp calculations produced above
#
#		-prefix = desired output prefix string

gridSize=`3dinfo -di <run+orig>`

3dNwarpApply -master struct_ns+tlrc \
-dxyz $gridSize \
-source <run+orig> \
-nwarp "anat.un.aff.qw_WARP.nii mat.<run>.warp.aff12.1D" \
-prefix tmp_<run>_nomask




### Step 4 - concatenate warp calculations to move the volreg base into template space
#
# - only the structural alignment and non-linear calcs are needed

cat_matvec -ONELINE \
anat.un.aff.Xat.1D \
struct_al_junk_mat.aff12.1D -I > mat.basewarp.aff12.1D




### Step 5 - warp EPI volreg base to template space
#
#	- this uses a different 1D warp matrix, made in the previous step

3dNwarpApply -master struct_ns+tlrc \
-dxyz $gridSize \
-source <epi_vr_base+orig> \
-nwarp "anat.un.aff.qw_WARP.nii mat.basewarp.aff12.1D" \
-prefix final_epi_vr_base
