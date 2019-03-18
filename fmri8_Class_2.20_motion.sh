#!/bin/bash







### Step 0: set up for timing files
#
# a) Get each subject's timing matrix from Vedder/Bootamp/Timing_files
#
# b) Remove the first line (column names) of the text file




### Step 1: convert timing.txt to 1D
#
#  This will make a 1D file for each column of the matrix
#
# 		-files = input txt file, a binary matrix
#
# 		-tr = time (seconds) indicated by each row of matrix
#
# 		-nruns = number of runs in phase
#
# 		-offset = start time later

make_stim_times.py -files <timing_file.txt> -prefix <Test1_TF_4_behVect> -tr 3.5 -nruns 2 -offset 0.5




### Step 2: create motion files
#
# Create demeaned motion files for each run in phase
#
#		-demean = demean each run - new mean of each run = 0
#
#		-split_into_pad_runs = separate out file by runs

nruns=<number of runs in phase>

cat dfile.TEST1*.1D > dfile_rall_<phase>.1D
1d_tool.py -infile dfile_rall_<phase>.1D -set_nruns $nruns -demean -write motion_demean_<phase>.1D
1d_tool.py -infile motion_demean_<phase>.1D -set_nruns $nruns -split_into_pad_runs mot_demean_<phase>




### Step 3: create censor files
#
# Censor TRs that move too much with respect to previous TR
#		> 0.3 mm or degrees
#
# Also censor preceding TR

1d_tool.py -infile dfile_rall_<phase>.1D -set_nruns $nruns -show_censor_count -censor_prev_TR -censor_motion 0.3 motion_<phase>
cat out.cen.<phase>*.1D > outcount_censor_<phase>.1D
1deval -a motion_<phase>_censor.1D -b outcount_censor_<phase>.1D -expr "a*b" > censor_<phase>_combined.1D
