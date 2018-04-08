#!/usr/bin/env bash
# copy java to pf
javaDir=$pfDir/java
makeDir $javaDir
for javaTgz in `ls -d $cloudDir/java/$system/*.tar.gz 2>/dev/null`; do
	tarDir=$(tar -tf $javaTgz | head -n 1)
	tarDir=${tarDir%/}
	destFolder=$(basename $javaTgz | sed 's/\.tar\.gz//g' | sed "s/-$system//g")
	if [ -d "$javaDir/$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		tar -zxf $javaTgz --transform "s/$tarDir/$destFolder/" -C $javaDir
		echo "$javaTgz extracted to $javaDir"
	fi
done

for javaDmg in `ls -d $cloudDir/java/$system/*.dmg 2>/dev/null`; do
	mountDir=`hdiutil attach $javaDmg | awk 'FNR==2{print substr($0, index($0, $3))}'`;
	pkgFile=`find "${mountDir}" -name "*.pkg" 2>/dev/null | head -n 1`
	majorVersion=`echo $javaDmg | awk -F- '{print $(NF-2)}' | cut -d'u' -f1`
	patchVersion=`echo $javaDmg | awk -F- '{print $(NF-2)}' | cut -d'u' -f2`
	destFolder=jdk-1.${majorVersion}.0_${patchVersion}-x64
	if [ -d "$javaDir/$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		rm -rf /tmp/$destFolder
		rm -rf /tmp/$destFolder-unzipped
		pkgutil --expand "$pkgFile" /tmp/$destFolder
		payloadFile=/tmp/$destFolder/jdk1${majorVersion}0${patchVersion}.pkg/Payload
		mkdir /tmp/$destFolder-unzipped
		mkdir "$javaDir/$destFolder"
		tar -zxf $payloadFile -C /tmp/$destFolder-unzipped
		cp -R /tmp/$destFolder-unzipped/Contents/Home/* "$javaDir/$destFolder/"
	fi
done

#verify java
javaDir=$pfDir/java
for specJava in `ls -d $javaDir/jdk-*`; do
	echo -e "${CYAN}Verifying $specJava${NC}"
	# verify version
	expectedJavaVersion=$(echo $specJava | awk -F- '{print $(NF-1)}' | tr 'u' '_')
	actualJavaVersion=$($specJava/bin/java -version 2>&1 | grep -i version)
	if [[ $actualJavaVersion == *"$expectedJavaVersion"* ]]; then
		echo -e "    ${GREEN}Java version is correct - $actualJavaVersion${NC}"
	else
		echo -e "    ${RED}Java version is not correct - expected: $expectedJavaVersion, got: $actualJavaVersion${NC}"
	fi
	#verify platform
	expectedPlatform=$(echo $specJava | awk -F- '{print $NF}')
	is64=$($specJava/bin/java -version 2>&1 | grep -i "64-Bit")
	actualPlatform="x64"
	if [ "$is64" == ""  ]; then
		actualPlatform="i586"
	fi
	if [ "$expectedPlatform" == "$actualPlatform" ]; then
		echo -e "    ${GREEN}Java platform is correct - $actualPlatform${NC}"
	else
		echo -e "    ${RED}Java platform is not correct - expected: $expectedPlatform, got: $actualPlatform${NC}"
	fi
done

#add java variables
createVariables1 java JAVA "awk -F- '{print \$(NF-1)}' | cut -d'.' -f2"


