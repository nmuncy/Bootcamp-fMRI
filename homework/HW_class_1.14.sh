#!/bin/bash



# Task 1 - write a single function that determines and prints out:
#
# 	1) The name of the directory containging the dicoms
#
# 	2) The patient age, sex, weight, TR, TE, and flip angle from the t1 header
#
# 	3) TR, TE, and flip angles from EPI headers,
#
# 	Feed dicom header info from each directory in /Volumes/Vedder/Bootcamp/Practice_data/s1295/data/


cat << EOF

Task: write a single function that determines and prints out:

 	1) The name of the directory containging the dicoms
 	2) The patient age, sex, weight, TR, TE, and flip angle from the t1 header
 	3) TR, TE, and flip angles from EPI headers,

 	Do this for each directory in /Volumes/Vedder/Bootcamp/Practice_data/s1295/data/

EOF





function PrintOut(){

	local dir=$1
	local input=$2

	local prot=`dicom_hdr $input | grep '0018 0024' | sed 's/.*\*//'`
	local age=`dicom_hdr $input | grep "0010 1010" | sed 's/.*\///'`
	local sex=`dicom_hdr $input | grep "0010 0040" | sed 's/.*\///'`
	local weight=`dicom_hdr $input | grep "0010 1030" | sed 's/.*\///'`
	local TR=`dicom_hdr $input | grep "0018 0080" | sed 's/.*\///'`
	local TE=`dicom_hdr $input | grep "0010 1010" | sed 's/.*\///'`
	local FA=`dicom_hdr $input | grep "0010 1010" | sed 's/.*\///'`

	if [ "$prot" == tfl3d1_ns ]; then

		echo "Dir = $dir"
		echo "Age = $age"
		echo "Sex = $sex"
		echo "Wgt = $weight"
		echo "TR = $TR"
		echo "TE = $TE"
		echo "FA = $FA"
	else
		echo "Dir = $dir"
		echo "TR = $TR"
		echo "TE = $TE"
		echo "FA = $FA"
	fi

}


refDir=/Volumes/Vedder/Bootcamp/Practice_data/s1295/data
cd $refDir

for i in $( echo * ); do

	PrintOut $i ${refDir}/${i}/IM*01.dcm
	echo
done
