#!/bin/bash



### --- Notes
#
# 1) when copying afni functional data, use 3dcopy instead of cp.
#
# 2) do the following for each participant, save the output to
#		that participant's directory



### Step 1: Get files into correct name
#
# the generated script is very persnickety
#
# the subjects number (e.g. s1295) will be needed


# a)
3dcopy full_mask+tlrc full_mask.<subjectNumber>+tlrc
cat outcount.TEST1*.1D > outcount_all_<phase>.1D


# b) Copy each original run (raw) data to be named in the following format:
#
#	pb00.<subjectNumber>.r<runNumber>.tcat+orig
#
#	example - run1+orig -> pb00.s1295.r01.tcat+orig


# c) Copy each volreg_clean file to be named in the following format
#
# 	pb02.<subjectNumber>.r<runNumber>.volreg+tlrc
#
# 	example - run1_volreg_clean+tlrc -> pb02.s1295.r01.volreg+tlrc


# d) Copy decon residual file to be named: errts.<subjectNumber>+tlrc
#
#	example - T1_errts+tlrc -> errts.s1295+tlrc



### Step 2: generate script
gen_ss_review_scripts.py \
	-subj <subjectNumber> \
	-rm_trs 0 \
	-motion_dset dfile_rall_<phase>.1D \
	-outlier_dset outcount_all_<phase>.1D \
	-enorm_dset  motion_<phase>_enorm.1D \
	-mot_limit 0.3 \
	-out_limit 0.1 \
	-xmat_regress X.<deconName>.xmat.1D \
	-xmat_uncensored X.<deconName>.nocensor.xmat.1D \
	-stats_dset <decon_stats+tlrc> \
	-final_anat final_anat+tlrc \
	-final_view tlrc \


### Step 3: run script, save output
./\@ss_review_basic | tee out_summary.txt
