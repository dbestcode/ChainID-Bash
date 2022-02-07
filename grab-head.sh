#!/bin/bash
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
#    echo $line
fi



done < $1
