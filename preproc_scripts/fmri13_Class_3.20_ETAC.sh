#!/bin/bash






###--- Notes
#
# The goal of this script is to run group-level analyses on participants
# who did not move too frequently. Multiple p-values and blurs will be used
# per the ETAC method. The output will then be organized to be more manageable,
# which is useful when you are running multiple group-level tests.
# Run this in your group analysis dir.




### Step 1: determine sub-bricks of interest
#
# use 3dinfo -verb on your deconvolved file to determine
#	which sub-brick number is associated with the beta-coefficient
#	of interest. We will contrast "Hit" with "FA".
#
#	e.g. sub-brick #1 'Hit#0_Coef' = sub-brick 1 is for Hits
#		make sure to pull the brick for Coef, and not Tstat




### Step 2: construct participant lists
#
# Two variables (ListA, ListB) will hold which participants are included
#	in the analysis.
#
# Each variable (ListA/B) needs to hold both a subject identifier as well
#	as the path to the input file and the sub-brick holding the beta of
#	interest.
#
#		e.g. echo $ListA = s1295 /path/to/s1295/T1_stats+tlrc[50] s1859 /path/to/s1859/T1_stats+tlrc[50]
#			 echo $ListB = s1295 /path/to/s1295/T1_stats+tlrc[53] s1859 /path/to/s1859/T1_stats+tlrc[53]


# Function for your convenience - will search an array for a string
MatchString () {
	local e match="$1"
	shift
	for e; do
		[[ "$e" == "$match" ]] && return 0
	done
	return 1
}




### Step 3: Run ETAC
#
# I recommend requesting 10 ppn, 40GB of RAM and > 10hours of walltime.
#
# Syntax is provided to make things easier for this step and the next.
#	If you have your subject lists (ListA,B) created and mask named
#	the same then this should run.
#
# 	-paired	= paired t-test
#	-mask 	= which voxels to include in the analysis
#	-prefix = desired output name
#				there will be several output files
#	-prefix_clustsim = desired output of noise simulations
#	-ETAC 	= use new ETAC method
#	-ETAC_blur = list of blurs to use
#				smallest should be 1.5*voxel dim
#	-ETAC_opt = etac options
#				we are using nearest neighbors = 1, 2-sided testing, multiple p-values
#	-setA A = list of data for behavior A
#	-setB B = list of data for behavior B


out=T1_ETAC_Decon_Hit-FA
blurArr=(4 6 8)
pvalArr=(0.01 0.005 0.001)
blur=`echo ${blurArr[@]}`

unset pval_all
for i in ${pvalArr[@]}; do
	pval_all+="${i},"
done
pval=${pval_all%?}



3dttest++ \
-paired \
-mask Intersection_GM_mask+tlrc \
-prefix $out \
-prefix_clustsim ${out}_clustsim \
-ETAC \
-ETAC_blur $blur  \
-ETAC_opt name=NN1:NN1:2sid:pthr=$pval \
-setA A $listA \
-setB B $listB




### Step 4: Organize output
#
# ETAC writes out numerous files. This section is to rename and extract some
# of the more useful files, organize them to not get overwhelmed.
#
# The syntax is given, and should run just fine if ETAC worked.
#
# - FINAall_* is the final, combined file across all p-values and blurs
#		This will be left in the group analysis dir
#
# - ${out}_clustsim.NN1.ETACmaskALL.*nii.gz holds all the information
#		in separate sub-bricks. We will use 3dbucket to extract each blur
#		and 3dmask_tool to collapse across the various p-values.
#		These will be moved to etac_indiv for use later
#
# - All other files will be moved to etac_extra, and the script will be moved
#		to etac_scripts


3dcopy ${out}_clustsim.NN1.ETACmask.global.2sid.5perc.nii.gz FINALall_${out}+tlrc

numPval=${#pvalArr[@]}
numBlur=${#blurArr[@]}

blurC=0; pvalC=0
while [ $blurC -lt $numBlur ]; do

	unset hBrick
	for ((j=1; j<=$numPval; j++)); do
		hBrick+="$pvalC,"
		let pvalC=$[$pvalC+1]
	done
	hBrick=${hBrick%?}

	3dbucket -prefix FINAL_b${blurArr[$blurC]}_${out} ${out}_clustsim.NN1.ETACmaskALL.global.2sid.5perc.nii.gz[$hBrick]
	3dmask_tool -input FINAL_b${blurArr[$blurC]}_${out}+tlrc -union -prefix FINAL_b${blurArr[$blurC]}_allP_${out}

	let blurC=$[$blurC+1]
done


mkdir etac_{extra,scripts,indiv}
mv *.sh etac_scripts
mv FINAL_b* etac_indiv
mv Group* etac_extra
mv Prior* etac_extra
mv global* etac_extra
