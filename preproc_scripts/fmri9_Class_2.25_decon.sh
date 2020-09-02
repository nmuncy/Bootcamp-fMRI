#!/bin/bash




#3dDeconvolve -input TEST11_scale+tlrc TEST12_scale+tlrc \
#-censor censor_TEST_combined.1D \
#-polort A -float \
#-num_stimts 17 \
#-stim_file 1 mot_demean_TEST.r01.1D'[0]' -stim_base 1 -stim_label 1 mot_1 \
#-stim_file 2 mot_demean_TEST.r01.1D'[1]' -stim_base 2 -stim_label 2 mot_2 \
#-stim_file 3 mot_demean_TEST.r01.1D'[2]' -stim_base 3 -stim_label 3 mot_3 \
#-stim_file 4 mot_demean_TEST.r01.1D'[3]' -stim_base 4 -stim_label 4 mot_4 \
#-stim_file 5 mot_demean_TEST.r01.1D'[4]' -stim_base 5 -stim_label 5 mot_5 \
#-stim_file 6 mot_demean_TEST.r01.1D'[5]' -stim_base 6 -stim_label 6 mot_6 \
#-stim_file 7 mot_demean_TEST.r02.1D'[0]' -stim_base 7 -stim_label 7 mot_7 \
#-stim_file 8 mot_demean_TEST.r02.1D'[1]' -stim_base 8 -stim_label 8 mot_8 \
#-stim_file 9 mot_demean_TEST.r02.1D'[2]' -stim_base 9 -stim_label 9 mot_9 \
#-stim_file 10 mot_demean_TEST.r02.1D'[3]' -stim_base 10 -stim_label 10 mot_10 \
#-stim_file 11 mot_demean_TEST.r02.1D'[4]' -stim_base 11 -stim_label 11 mot_11 \
#-stim_file 12 mot_demean_TEST.r02.1D'[5]' -stim_base 12 -stim_label 12 mot_12 \
#-stim_times 13 timing_files/Test1_TF_4_behVect.01.1D "BLOCK(3,1)" -stim_label 13 beh_T1Hit \
#-stim_times 14 timing_files/Test1_TF_4_behVect.02.1D "BLOCK(3,1)" -stim_label 14 beh_T1FA \
#-stim_times 15 timing_files/Test1_TF_4_behVect.03.1D "BLOCK(3,1)" -stim_label 15 beh_T1CR \
#-stim_times 16 timing_files/Test1_TF_4_behVect.04.1D "BLOCK(3,1)" -stim_label 16 beh_T1Miss \
#-stim_times 17 timing_files/Test1_TF_4_behVect.05.1D "BLOCK(3,1)" -stim_label 17 beh_NR \
#-jobs 6 -bout -fout -tout \
#-x1D X.T1.xmat.1D -xjpeg X.T1.jpg -x1D_uncensored X.T1.nocensor.xmat.1D \
#-errts T1_errts \
#-bucket T1_stats
