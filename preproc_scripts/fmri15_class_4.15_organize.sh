#!/bin/bash


parDir=/Volumes/Vedder/Bootcamp/Nate/Analyses/grpAnalysis
workDir=${parDir}/etac_betas
statsDir=${parDir}/etac_stats
mkdir $statsDir


compList=(T1)
arrT1=(RAMTG RMPFC LMPFC LAG RPUT RPCU RSFG RIFS)


cd $workDir

for i in ${compList[@]}; do

	# Rename cluster to anat
	out=All_Betas_${i}.txt
	> $out
	eval arrHold=(\${arr${i}[@]})

	for k in Betas_${i}_c*; do

		tmp=${k%.*}
		num=${tmp##*_c}
		arrNum=$(($num-1))

		cat $k > Betas_${i}_${arrHold[${arrNum}]}.txt
		echo Betas_${i}_${arrHold[${arrNum}]}.txt >> $out
	done
done


> All_list.txt
for i in All_Betas*; do
	echo $i >> All_list.txt
done
