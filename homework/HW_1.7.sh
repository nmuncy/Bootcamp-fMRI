#!/bin/bash



### Task 1: Grep
echo "Task 1 - Use grep to extract header data from Bootcamp/Scans/Kirwan_Training_101018 Run_3,"
echo "		  and print out the following:"
echo "        (You'll have to figure out how to strip off the extra stuff)"
echo

data=/Volumes/Vedder/Bootcamp/Scans/Kirwan_Training_101018/Research_Mcpherson*/EPI_Run_3/IM-0005-0001.dcm

sexH=`dicom_hdr $data | grep '0010 0040'`
ageH=`dicom_hdr $data | grep '0010 1010'`
trH=`dicom_hdr $data | grep '0018 0080'`
teH=`dicom_hdr $data | grep '0018 0081'`
flH=`dicom_hdr $data | grep '0018 1314'`

echo "	Subj Sex   = ${sexH##*\/}"
echo "	Subj Age   = ${ageH##*\/}"
echo "	Scan TR    = ${trH##*\/} ms"
echo "	Scan TE    = ${teH##*\/} ms"
echo "	Scan Flip  = ${flH##*\/}"


### Task 2: determine block length
echo
echo
echo "Task 2 - Calculate the length of a block"
echo "        (You'll have to figure out how to limit the precision of floating point variables)"
echo
hold=${trH##*\/}
numTR=`ls ${data/%IM*}IM* | wc -l`
TRlen=$(($hold/1000))

total=$(($numTR*$TRlen))
out=`echo "scale=2; $total/60" | bc -l`
echo "	Block length was $out minutes"


### Task 3: append var
echo
echo
echo "Task 3 - Append a variable to hold the first 5 subject ID numbers"
echo
workDir=/Volumes/Vedder/Bootcamp/Nate
cd $workDir

c=1; for i in s*; do
	if [ $c -le 5 ]; then
		subj+="$i "
	fi
	let c=$[$c+1]
done

echo "	The subjects in this study are: $subj"
echo
