#!/bin/bash
#hashing the data in the block
RED=$(tput setaf 1) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3)
NC=$(tput sgr0)
online="${GREEN}PASS$NC"
offline="${RED}FAIL$NC"

#ping -c 1 "$hostname" > /dev/null 2>&1 && state=$online || state=$offline
#printf 'Network %-15s: %s\n' "$hostname" "$state"
if [ -f $1 ]; then
	printf '%-15s: %s\n' "BLOCK" "$1"
	blkhash=($(./grab-data.sh $1|md5sum))
else
	printf '%-15s: %s\n' "$1" "$offline"
	echo FILE DOES NOT EXIST
	exit 1
fi

#reading the "tag" of its claimed hash
hashtag=$(cat $1 | grep -o -P '(?<=<DATA-HASH>).*(?=</DATA-HASH>)')
#printf '%-15s: %s\n' "DATA TEST" "'$blkhash' == '$hashtag'"

if [[ $blkhash == $hashtag ]]; then
	printf '%-15s: %s\n' "DATA VALID" "$online"
else
	printf '%-15s: %s\n' "DATA VALID" "$offline"
fi

#find last block
last=$(cat $1 | grep -o -P '(?<=<LAST>).*(?=</LAST>)')
#check if this is a file
if [ -f $last ]; then
	printf '%-15s: %s\n' "LAST BLOCK" "$last"
	#read the tag of the hash in block in question
	lastheadhash=$(cat $1 | grep -o -P '(?<=<LAST-BLOCK-HEAD-HASH>).*(?=</LAST-BLOCK-HEAD-HASH>)')
else
	printf '%-15s: %s\n' "LAST BLOCK" "$offline"
	echo "Genesis Block or FAIL"
	exit 1
fi
#hash the data from the last block's head
hashtaglast=($(./grab-head.sh $last|md5sum))
#printf '%-15s: %s\n' "LAST HEAD" "$hashtaglast = $lastheadhash"

if [[ $hashtaglast == $lastheadhash ]]; then
	printf '%-15s: %s\n' "LAST VALID" "$online"
else
	printf '%-15s: %s\n' "LAST VALID" "$offline"
	echo 0;exit 1
fi
printf "\n"

./verify-block.sh $last
