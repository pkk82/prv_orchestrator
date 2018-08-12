#!/usr/bin/env bash

copyFamilyAsDirs lein
createVariables2 lein lein

for instruction in `cat $varFile | grep LEIN | grep PF_DIR | grep -v PATH`; do
	if [[ "$instruction" == *"="* ]]; then
		leinDir=$(echo $instruction | awk -F/ '{print $(NF)}')
		chmod u+x $pfDir/lein/$leinDir/lein
	fi
done
