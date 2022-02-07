#162TRPRZvdgLVNksMoMyGJsYBfYtB4Q8tM
#/bin/bash
# block ID creator
clear
# validate last block-----------------------------------------
blast=$1
#blkhash=($(./ grab-data.sh $blast|md5sum))
###########################
found=0
starttag="<DATA>"
endtag="</DATA>"
while IFS= read -r line; do
	if [[ $line == *"$endtag"* ]]; then
		break
	fi
	if [ $found -eq 1 ]
	then
		blockdata=$blockdata$line
	fi
	if [[ $line == *"$starttag"* ]]; then
			found=1
	fi
done < $blast
echo $blockdata
exit 1
#####################


#echo $blkhash
HASHTAG=$(cat $blast | grep -o -P '(?<=<DATA-HASH>).*(?=</DATA-HASH>)')
#echo $HASHTAG
if [[ $blkhash == $HASHTAG ]]; then
	echo CHECKING LAST BLOCK:	$blast			VERFICATION:PASS
	echo ""
else
	echo LAST BLOCK:	$blast				VERFICATION:FAIL
	echo BLOCK INVAILD, PLEASE DELETE FILE:$blast
	exit 1
fi

#------------------------------------------------------------

#temp file fore building data and hashing it
tempfile=/tmp/reuiewfdsjklweru.tmp
ext=".LOK"
#Name block and hash head from last block
bid=$(< /dev/urandom tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo Creating Block:$bid
bfile=$bid$ext
lhash=($(./grab-head.sh $blast|md5sum))

#Gather info for ID from user
echo -n First Name:
read fname
echo -n Middle Name:
read mname
echo -n Last Name:
read lname
echo -n DOB:
read dob
echo -n 'Notes(This is not editable after this point):'
read notes
# MK data file to hash
echo "<NOTE>">>$tempfile
echo $notes>>$tempfile
echo "</NOTE>">>$tempfile
echo "<FIRST-NAME>">>$tempfile
echo $fname>>$tempfile
echo "</FIRST-NAME>">>$tempfile
echo "<MIDDLE-NAME>>">>$tempfile
echo $mname>>$tempfile
echo "</MIDDLE-NAME>">>$tempfile
echo "<LAST-NAME>">>$tempfile
echo $lname>>$tempfile
echo "</LAST-NAME>">>$tempfile
echo "<DOB>">>$tempfile
echo $dob>>$tempfile
echo "</DOB>">>$tempfile

bhash=($(md5sum $tempfile))
#begin adding info to header file
echo "<HEAD>">>$bfile
echo "<ID>$bid</ID>">>$bfile
echo "<DATA-HASH>$bhash</DATA-HASH>">>$bfile
echo "<LAST>$blast</LAST>">>$bfile
echo "<LAST-BLOCK-HEAD-HASH>$lhash</LAST-BLOCK-HEAD-HASH>">>$bfile
echo "<CREATED>`date`</CREATED>">>$bfile
echo "</HEAD>">>$bfile
#add data already created
echo "<DATA>">>$bfile
cat $tempfile>>$bfile
echo "</DATA>">>$bfile
echo BLOCK COMPLETE.
./hasho.sh 2 $bfile

rm $tempfile

exit 1


<HEAD>
<ID>CZNzUleKVPlwelDWRMi8iswYi1K7pnSX</ID>
<DATA-HASH></DATA-HASH>
<LAST>0000</LAST>
<LAST-BLOCK-HEAD-HASH>0000</LAST-BLOCK-HEAD-HASH>
<CREATED>Mon Jan  3 12:40:26 EST 2022</CREATED>
</HEAD>

<DATA>
<NOTE>This is the Genesis Block.  It was manually made in 2022
Salt:16uEbgcKAHXD0qB5Xe0M9uXQOzS19Rkj1GuPWW7CwDhmZZK3QqybsXEKxjYfQzcGFfgslU9lAmMKF4Bdj8Ao8S6DVEwuk2Nl</NOTE>
<FIRST-NAME>XXX</FIRST-NAME>
<MIDDLE-NAME>XXX</MIDDLE-NAME>
<LAST-NAME>XXX</LAST-NAME>
<DOB>01/01/0001</DOB>
</DATA>
<PROOF>
</PROOF>
