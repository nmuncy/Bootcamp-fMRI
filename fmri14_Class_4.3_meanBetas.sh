#!/bin/bash



###--- Notes:
#
# A cannibalized script from a project. This script will:
#
# 	a) make clusters from etac output
# 	b) blur deconvolved data according to the blur used for the cluster
#	c) pull mean beta-coefficients of the cluster and write it to an
#		output file.




### Variables
#
# This script is written to orient itself from this section. Assuming you
# have the same organization and file names as me, simply update this section
# and run the script.

workDir=~/compute/Bootcamp/Nate										# Dir with all subjects dir
grpDir=${workDir}/Analyses/grpAnalysis								# where the ETAC output is
clustDir=${grpDir}/etac_clusters									# to be made
outDir=${grpDir}/etac_betas											# to be made

fileArr=(T1)														# decon files from which betas will be extracted - should match previous step
arrA=(1)															# sub-bricks corresponding to $fileArr
arrB=(4)
arrLen=${#arrA[@]}

blurArr=(4 6 8)														# blurs used in ETAC
blurLen=${#blurArr[@]}




### function - search array for string
MatchString (){
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}




### make clusters, tables
#
# This will render group-level clusters for each blur used in ETAC.
# It will also produce a table.


# make output dir
mkdir $outDir $clustDir
cd ${grpDir}/etac_indiv

# for each mask
for i in FINAL_*allP*.HEAD; do

	# determine names from file name
	tmp1=${i%_ET*}; pref=${tmp1##*_}
	tmp2=${i#*_}; blur=${tmp2%%_*}

	# make cluster file
	if [ ! -f ${clustDir}/Clust_${pref}_${blur}_table.txt ]; then

		3dclust -1Dformat -nosum -1dindex 0 \
		-1tindex 0 -2thresh -0.5 0.5 -dxyz=1 \
		-savemask Clust_${pref}_${blur}_mask \
		1.01 5 $i > Clust_${pref}_${blur}_table.txt
	fi
done

# keep things clean
mv Clust* $clustDir



### pull mean betas
#
# for e/cluster from e/comparison from e/subject
# For each cluster, blur the deconvolved data appropriately and
# extract the mean beta coefficient. Write it to a txt file in
# $outDir


cd $clustDir

# for each value of $fileArr
c=0; while [ $c -lt $arrLen ]; do

	# determine string, betas
	hold=${fileArr[$c]}
	betas=${arrA[$c]},${arrB[$c]}

	# make list of subjects to include, set it to array
	unset subjHold
	arrRem=(`cat ${grpDir}/info_rmSubj_${hold}.txt`)
	for i in ${workDir}/s*; do
		subj=${i##*\/}
		MatchString "$subj" "${arrRem[@]}"
		if [ $? == 1 ]; then
			subjHold+="$subj "
		fi
	done
	subjList=(${subjHold})


	# for each blur
	d=0; while [ $d -lt $blurLen ]; do

		blurInt=${blurArr[$d]}

		if [ -f Clust_${hold}_b${blurInt}_mask+tlrc.HEAD ]; then
			if [ ! -f Clust_${hold}_b${blurInt}_c1+tlrc.HEAD ]; then

				# determine number of clusters in Clust_mask
				3dcopy Clust_${hold}_b${blurInt}_mask+tlrc ${hold}_b${blurInt}.nii.gz
				num=`3dinfo Clust_${hold}_b${blurInt}_mask+tlrc | grep "At sub-brick #0 '#0' datum type is short" | sed 's/[^0-9]*//g' | sed 's/^...//'`

				# extract each cluster in Clust_mask, make it its own file
				for (( j=1; j<=$num; j++ )); do
					if [ ! -f Clust_${hold}_b${blurInt}_c${j}+tlrc.HEAD ]; then

						c3d ${hold}_b${blurInt}.nii.gz -thresh $j $j 1 0 -o ${hold}_b${blurInt}_${j}.nii.gz
						3dcopy ${hold}_b${blurInt}_${j}.nii.gz Clust_${hold}_b${blurInt}_c${j}+tlrc
					fi
				done
				rm *.nii.gz
			fi


			# for each individual cluster
			for i in Clust_${hold}_b${blurInt}_c*+tlrc.HEAD; do

				# determine names, name output, clear it
				tmp=${i##*_}
				cnum=${tmp%+*}
				print=${outDir}/Betas_${hold}_b${blurInt}_${cnum}.txt
				> $print

				# for each subject
				for j in ${subjList[@]}; do

					subjDir=${workDir}/${j}
					decon=stats

					# blur deconvovled data, according to cluster blur
					if [ ! -f ${subjDir}/${hold}_${decon}_blur${blurInt}+tlrc.HEAD ]; then
						3dmerge -prefix ${subjDir}/${hold}_${decon}_blur${blurInt} -1blur_fwhm $blurInt -doall ${subjDir}/${hold}_${decon}+tlrc
					fi

					# pull mean beta coefficient from blurred decon file, print it out
					file=${subjDir}/${hold}_${decon}_blur${blurInt}+tlrc
					stats=`3dROIstats -mask $i "${file}[${betas}]"`
					echo "$j $stats" >> $print
				done
			done
		fi
		let d=$[$d+1]
	done
	let c=$[$c+1]
done
