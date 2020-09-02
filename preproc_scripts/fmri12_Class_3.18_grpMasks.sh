#!/bin/bash



###--- Notes: 
#
# The goal is to construct a group-level intersection, gray matter mask.
#
#	- each participant has a file called "mask_epi_anat+tlrc" that will
#			be combined.
#
#	- then, a gray matter mask in template space will be constructed
#			and resampled into functional dimensions
#
#	- finally, these two masks will be multiplied with each other to produce
#			a final mask called Intersection_GM_mask+tlrc




### Step 1: Make a mean group-level intersection mask
#
# a) use the AFNI command 3dMean to make an average of all participant's
#		mask_epi_anat+tlrc files
#
# b) only include subjects that were not excluded
#		a single variable ($list) should hold the path to 
#
# c) use the form 3dMean -prefix <something> $list




### Step 2: Make a binary group-level intersection mask that is thresholded
#
# a) again, only include participants that should not be excluded ($list)
#
# b) use the AFNI command 3dmask_tool with the arguments
#		-input, -frac, prefix
#
# c) threshold at 0.3, and have the output called Group_epi_mask.nii.gz




### Step 3: Make a gray matter mask, resampled into functional dimensions
#
# a) combine the gray-matter priors we constructed for the template,
#		these are in priors_ACT and are called Prior2 and Prior4
#
# b) use the command c3d with the options -add and -o to add together the 
# 		two Priors, and call the output tmp_Prior_GM.nii.gz
#
# c) use the AFNI command 3dresample to resample tmp_Prior_GM.nii.gz
#		from structural to functional dimensions.
#
#		use the options:
#			-master - to reference a file to get proper dimensions
#			-rmode - use NN as the argument for this option
#			-input, use tmp_Prior_GM.nii.gz
#			-prefix, call the output tmp_Template_GM_mask.nii.gz




### Step 4: Multiply Group_epi_mask.nii.gz with tmp_Template_GM_mask.nii.gz
#
# a) use the c3d command to multiply these two files, with the options -multiply and -o
#		call the output tmp_Intersection_GM_prob_mask.nii.gz
#
# b) this output will be probabilistic, so it needs to be thresholded
#		use c3d with the -thresh and -o options
#		use thresh to turn everything between 0.1 and 1 to 1 and everything else 0
#		call the output tmp_Intersection_GM_mask.nii.gz
#
# c) finally, use 3dcopy to convert tmp_Intersection_GM_mask.nii.gz to Intersection_GM_mask+tlrc