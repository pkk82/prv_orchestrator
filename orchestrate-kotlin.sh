#!/usr/bin/env bash
# copy kotlin to pf
kotlinDir=$pfDir/kotlin
makeDir $kotlinDir
for kotlinZip in `ls -d $cloudDir/kotlin/kotlin-compiler-*.zip`; do
	kotlinSpec=$(echo $kotlinZip | awk -F/ '{print $(NF)}' | sed "s/.zip$//g")
	destFolder=$kotlinDir/$kotlinSpec
	if [ -d "$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		unzip -q $kotlinZip -d $kotlinDir
		mv $kotlinDir/kotlinc $destFolder
		echo "$kotlinZip extracted to $destFolder"
	fi

done

#verify kotlin
for specKotlin in `ls -d $kotlinDir/kotlin-compiler-*`; do
	# verify version
	expectedKotlinVersion=$(echo $specKotlin | awk -F- '{print $(NF)}')
	actualKotlinVersion=$($specKotlin/bin/kotlin -version 2>&1 | grep -i version)
	if [[ $actualKotlinVersion == *"$expectedKotlinVersion"* ]]; then
		echo -e "${GREEN}Kotlin version is correct - $expectedKotlinVersion${NC}"
	else
		echo -e "${RED}Kotlin version is not correct - expected: $expectedKotlinVersion, got: $actualKotlinVersion${NC}"
	fi
done

#add kotlin variables
maxMajorVersion=0
maxMinorVersion=0
echo "# kotlin" >> $varFile
for specKotlin in `ls -d $kotlinDir/kotlin-compiler-*`; do
	majorVersion=$(echo $specKotlin | awk -F- '{print $(NF)}' | cut -d'.' -f1)
	minorVersion=$(echo $specKotlin | awk -F- '{print $(NF)}' | cut -d'.' -f2)
	version="${majorVersion}_${minorVersion}"
	if (( 10000 * $majorVersion + $minorVersion > 10000 * $maxMajorVersion + $maxMinorVersion )); then
		maxMajorVersion=$majorVersion
		maxMinorVersion=$minorVersion
	fi
	echo "export KOTLIN${version}_HOME=$specKotlin" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
	echo "alias use-kotlin-${version}='export KOTLIN_HOME=\$KOTLIN${version}_HOME; export PATH=\$KOTLIN_HOME/bin:\$PATH'" >> $aliases
done;
echo "export KOTLIN_HOME=\$KOTLIN${maxMajorVersion}_${maxMinorVersion}_HOME" >> $varFile
echo "export PATH=\$KOTLIN_HOME/bin:\$PATH" >> $varFile
. $varFile



