#!/bin/bash





### --- Notes
#
# 1) each step below must be done with each block of fMRI data (Test11, Test12)
#
# 2) <something> = change this
#
# 3) steps 1-3 are just described - figure this out
#
#		step 1 changes file formats
#		step 2 is to get a variable that holds the total number of seconds for each block
#		step 3 is to use the total number of seconds to calculate the number of polynomials required
#			the output of step 3 is the argument for the step 4 -polort option, and must be integer.



### Step 1: convert from nifti format to afni
#
# 	writes two files - BRIK & HEAD
#
#	syntax to convert: 3dcopy <block>.nii.gz <block>+orig



### Step 2: determine length of scan in seconds - multiply number of TRs by TR length
#
# 	get num TRs: 3dinfo -ntimes <block+orig>
#
# 	get TR length: 3dinfo -tr <block+orig>



### Step 3: determine number of polynomial regressors - must be integer
#
# 	number of polynomial (numPol) = 1 + (length of scan in seconds)/150
#
# 	round to nearest integer: printf "%.0f" <2.8>



### Step 4: determine of outliers
#
#	-automask = afni generates a brain mask
#
#	-fraction = report proportion of voxels, not count
#
#	-polort = number of polynomial regressors, argument from step 3
#
#	-legendre = use Legendre polynomials
#
#	<block>+orig = output of step 1

3dToutcount -automask -fraction -polort <$numPol> -legendre <block>+orig > outcount.<block>.1D



### Step 5: determine censors needed
#
#	-a = input, from step 4
#
# 	-expr "blah" = everything greater than 0.1

1deval -a outcount.<input>.1D -expr "1-step(a-0.1)" > out.cen.<block>.1D
