#162TRPRZvdgLVNksMoMyGJsYBfYtB4Q8tM
#!/bin/bash
# block ID creator
# Depends:
#   grep
#   md5sum

VerifyBlock(){
    Test_Block_File=$1
    Test_Block_ID="$(echo $Test_Block_File | sed 's/^.*\///')"
    if [ -f $Test_Block_File ]; then
    	printf '%-15s: %s\n' "BLOCK" "$Test_Block_ID"
        md5sum $Test_Block_File
    	blkhash=($(getData $Test_Block_File|md5sum))
    else
    	printf '%-15s: %s\n' "$Test_Block_File" "$Fail"
    	echo FILE DOES NOT EXIST
    	#exit 1
    fi

    #reading the "tag" of its claimed hash
    hashtag=$(cat $Test_Block_File | grep -o -P '(?<=<DATA-HASH>).*(?=</DATA-HASH>)')
    #printf '%-15s: %s\n' "DATA TEST" "'$blkhash' == '$hashtag'"

    if [[ $blkhash == $hashtag ]]; then
    	printf '%-15s: %s\n' "DATA VALID" "$Pass"
    else
    	printf '%-15s: %s\n' "DATA VALID" "$Fail"
    fi

    #find last block
    Prior_Block_Filename=$Chain_Dir/$(cat $Test_Block_File | grep -o -P '(?<=<LAST>).*(?=</LAST>)')
    Prior_Block_ID=$(cat $Test_Block_File | grep -o -P '(?<=<LAST>).*(?=</LAST>)')
    #check if this is a file
    if [ -f $Prior_Block_Filename ]; then
    	printf '%-15s: %s\n' "LAST BLOCK" "$Prior_Block_ID"
    	#read the tag of the hash in block in question
    	lastheadhash=$(cat $Test_Block_File | grep -o -P '(?<=<LAST-BLOCK-HEAD-HASH>).*(?=</LAST-BLOCK-HEAD-HASH>)')
    else
    	printf '%-15s: %s\n' "LAST BLOCK" "$Fail"
    	echo "Genesis Block or FAIL?"
        return
    fi
    #hash the data from the last block's head
    hashtaglast=($(getData $Prior_Block_Filename|md5sum))
    if [[ $hashtaglast == $lastheadhash ]]; then
    	printf '%-15s: %s\n' "LAST VALID" "$Pass"
    else
    	printf '%-15s: %s\n' "LAST VALID" "$Fail"
        return
    fi
    printf "\n"

    VerifyBlock $Prior_Block_Filename
}


proveBlock(){
# calulate the file needed to make a particulre hash
# Hash begining with a number of zeros
# to increse diffculty add 0's to $Hash_Key and make last char the same length
    Solution_File="Solution.LOK"
    Hash_Key="bbbb"
    i=1
    # Make a New Solution File to test
    cp $1 $Solution_File
    echo "<PROOF>NDBEST $(date)">>$Solution_File
    while [ true ];do
    	i=$((i+1))
        if [ $((i%6)) -eq 0 ]; then
            echo -n "."
        fi
        	# append chars solution
    	echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1) >>$Solution_File
        # hash the file
    	blkhash=($(md5sum $Solution_File))
        # grab first chars of hash to test
    	Hash_Prefix="${blkhash: 0:4}"
        # test to see if hash has the correct number of zeros
    	if [[ $Hash_Prefix == $Hash_Key ]];then
            echo
    		echo "HASH CALCULATED:	$blkhash"
    		echo "ITERATIONS:	    $i"
    		echo -n "SIZE:		    "
   		    mv $Solution_File $1
    		du -h $1
    		break
    	fi
    done
}
#---------- grab-head ----------------------------------------------------------
getData() {
    found=0
    starttag="<DATA>"
    endtag="</DATA>"
    while IFS= read -r line; do
        if [[ $line == *"$endtag"* ]]; then
        #    echo $line
        	break
        fi

        if [ $found -eq 1 ]
        then
        	echo $line
        fi
        if [[ $line == *"$starttag"* ]]; then
        		found=1
        #    echo $line
        fi
    done < $1
}

#---------- grab-data ----------------------------------------------------------
getHead() {
    found=0
    starttag="<HEAD>"
    endtag="</HEAD>"
        while IFS= read -r line; do
        if [[ $line == *"$endtag"* ]]; then
        #    echo $line
        	break
        fi

        if [ $found -eq 1 ]
        then
        	echo $line
        fi
        if [[ $line == *"$starttag"* ]]; then
        		found=1
        fi
    done < $1
}

# ---------- begin script  -----------------------------------------------------
# empty arg and file checks
#~ if [ $# -ne 1 ]; then
#~ 	echo "Missing File!"
#~ 	echo "Usage: ChainID.sh [LAST BLOCK]"
#~ 	exit -1
#~ elif [ -f $1 ]; then
#~     echo "$1 FOUND"
#~ else
#~     echo "$1 IS NOT A FILE."
#~ 	exit -1
#~ fi

# Definitions
RED=$(tput setaf 1) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3)
NC=$(tput sgr0)
Pass="${GREEN}PASS$NC"
Fail="${RED}FAIL$NC"

# pull dirctory from conf file
raw_path="$(grep 'CHAIN_DIR' "$HOME/.chainid/chainid.conf" |sed 's/^.*=//')"
#Last_Block="$(grep 'LAST_BLOCK' "$HOME/.chainid/chainid.conf" |sed 's/^.*=//')"
# Chain_DIR is the location of the block chain
if [[ ( ! -d "${raw_path}" ) && "${raw_path:0:1}" = "~" ]]; then
    Chain_Dir="${HOME}${raw_path:1}"
else
    Chain_Dir="${raw_path}"
fi

Last_Block_Filename="$Chain_Dir/$(tail -n 1 $Chain_Dir/ChainList.csv)"
Last_Block_Hash=($(getData "$Last_Block_Filename"|md5sum))

if [ -f $Last_Block_Filename ]; then
    Last_Block_ID="$(tail -n 1 $Chain_Dir/ChainList.csv)"
else
    echo -e "LAST BLOCK:	$Last_Block_Filename				VERFICATION:$Fail\nFILE DOES NOT EXIST"
#	exit 1
fi
clear
VerifyBlock $Last_Block_Filename


# --- Validate last block  --- NO Longer needed as chain is verified
# make a hask of the data in the block
#Last_Block_Hash=($(getData "$Last_Block_Filename"|md5sum))
# grep the hash claimed by the block and compare to real has for validity
#Reported_Hash=$(cat $Last_Block_Filename | grep -o -P '(?<=<DATA-HASH>).*(?=</DATA-HASH>)')
#if [[ $Last_Block_Hash == $Reported_Hash ]]; then
#	echo -e "CHECKING LAST BLOCK:	$Last_Block_ID			VERFICATION:$Pass\n"
#else
#	echo -e "LAST BLOCK:	$Last_Block_Filename				VERFICATION:$Fail\nBLOCK INVAILD, PLEASE DELETE FILE:$Last_Block_Filename"
#	exit 1
#fi
#------------------------------------------------------------

#temp file for building data and hashing it
tempfile=/tmp/reuiewfdsjklweru.tmp
ext=".LOK"
#Name block and hash head from last block
Block_ID=$(< /dev/urandom tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo
echo "--- Enter Identifcation ---"
Block_Filename="$Chain_Dir/$Block_ID$ext"

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
{
    echo "<NOTE>"
    echo $notes
    echo "</NOTE>"
    echo "<FIRST-NAME>"
    echo $fname
    echo "</FIRST-NAME>"
    echo "<MIDDLE-NAME>>"
    echo $mname
    echo "</MIDDLE-NAME>"
    echo "<LAST-NAME>"
    echo $lname
    echo "</LAST-NAME>"
    echo "<DOB>"
    echo $dob
    echo "</DOB>"
} >> $tempfile
Data_Hash=($(md5sum $tempfile))

#begin adding info to header file
{
    echo "<HEAD>"
    echo "<ID>$Block_ID</ID>"
    echo "<DATA-HASH>$Data_Hash</DATA-HASH>"
    echo "<LAST>$Last_Block_ID</LAST>"
    echo "<LAST-BLOCK-HEAD-HASH>$Last_Block_Hash</LAST-BLOCK-HEAD-HASH>"
    echo "<CREATED>`date`</CREATED>"
    echo "</HEAD>"
    echo "<DATA>"
    cat $tempfile
    echo "</DATA>"
} >> $Block_Filename
rm $tempfile

echo -n "CREATING BLOCK:$Block_ID"

proveBlock $Block_Filename
echo "BLOCK CREATION COMPLETE: $Block_ID :$Pass"
echo $Block_ID.LOK >> "$Chain_Dir/ChainList.csv"

exit 1
