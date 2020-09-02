#!/bin/bash

#!/bin/bash

#SBATCH --time=05:00:00   # walltime
#SBATCH --ntasks=6   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=8gb   # memory per CPU core
#SBATCH -J "VR"   # job name



### --- Notes
#
# 1) The purpose of this step is to determine which TR had the least noise,
#		and create a file in that TR space.
#
# 2) This "minimum" TR could exist in any run, but lucky for us we are only
# 		dealing with two runs ATM



### Step 1: Create and append a variable that holds the number of TRs for each run
#
# Use 3dinfo -ntimes
# Call this tr_counts
# 	e.g. with two runs of 50 trs, tr_counts="50 50"



### Step 2: Combine all outcount.*.1D files using cat
#
# Call this outcount_all.1D



### Step 3: Determine which TR in the experiment had the least noise.
#
# Use 3dTstat for this
#	This sets $minindex to an integer, which represents the least noisy TR

minindex=`3dTstat -argmin -prefix - outcount_all.1D\'`



### Step 4: Figure out from which run $minindex came
#
# use the 1d_tool.py toolkit for this
#
# set the output to be an array (because multiple things are printed to stdout) called ovals
#	ovals[0] should be an integer of which run was least noisy
#	ovals[1] should be an integer of which TR within said run was least noisy
#
# set the output to different variables

ovals=(`1d_tool.py -set_run_lengths $tr_counts -index_to_run_tr $minindex`)

minoutrun=${ovals[0]}
minouttr=${ovals[1]}



### Step 4: Figure out which run $minoutrun corresponds to
#
# we keep things organized, so ovals[0]=01 is TEST11, and ovals[0]=02 is TEST12.
#
# call this run $baseRun



### Step 5: construct a file that references the minimum noisy TR
#
# the output file will be called epi_vr_base, use 3dbucket for this job
#	essentially, we pull out the single TR, call it epi_vr_base, and use this file
#	as a reference for future things
#
# also, print out your determinations for future reference

3dbucket -prefix epi_vr_base ${baseRun}+orig"[${minouttr}]"
echo "$minoutrun $minouttr $baseRun" > out_vr_base.txt
