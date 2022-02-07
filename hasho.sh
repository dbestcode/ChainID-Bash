#!/bin/bash
# a utill to calulate the file needed to make a particulre hash 
# Hash begining with a number of zeros
testfile="testhash"
solvevarfile="solve"
#switch based on $1 to pick hash diffilctuy
case $1 in

  1)
	proof="0"
    	;;
  2)
	proof="00"
    ;;
  3)
	proof="000"
    ;;
  4)
	proof="0000"
    ;;
  5)
	proof="00000"
    ;;
  *)
	echo "USAGE: n file_name"
	echo -n "unknown"
	exit 1
    ;;
esac

i=1
echo "<PROOF>NDBEST">$solvevarfile
while [ true ];do
	i=$((i+1))
	cp $2 $testfile
	echo -n $i>>$solvevarfile
	cat $solvevarfile>>$testfile
	echo "</PROOF>">>$testfile
	blkhash=($(md5sum $testfile))
#	cat $blkhash
	lastchar="${blkhash: 0:$1}"
	echo $lastchar
#	echo $i
	if [[ $lastchar == $proof ]];then
		clear
		echo "FILE: 		$2"
		echo "HASH CALCULATED:	$blkhash"
		echo "ITERATIONS:	$i"
		echo -n "SIZE:		"
		du -h $testfile
		break
	fi
done
