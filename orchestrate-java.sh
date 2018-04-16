#!/usr/bin/env bash
# copy java to pf
javaDir=$pfDir/java
makeDir $javaDir

currentDir=`pwd`
rm -rf /tmp/*
for javaBinPath in `ls -d $cloudDir/java/$system-new/*bin 2>/dev/null`; do
	javaBin=`basename $javaBinPath`
	destDir=`echo $javaBin | sed 's/\.bin//g' | sed 's/j2sdk/jdk/g' | sed 's/amd64/x64/g' | sed "s/-$system//g"`
	cp $javaBinPath /tmp/$javaBin
	chmod u+x /tmp/$javaBin
	workingDir="/tmp/$destDir"
	mkdir $workingDir
  cd $workingDir
	/tmp/$javaBin
	javaFile=`find "$workingDir" -name "java" 2>/dev/null | head -n 1`

	if [ -f "$javaFile" ]; then
		if [ -d "$javaDir/$destDir" ]; then
			echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
		else
			dirName=`ls $workingDir`
			mkdir $javaDir/$destDir
			cp -r $workingDir/$dirName/* $javaDir/$destDir/
		fi
	else
			echo -e "${RED}$workingDir does not contain java${NC}"
	fi



done
cd $currentDir


# for javaTgz in `ls -d $cloudDir/java/$system/*.tar.gz 2>/dev/null`; do
# 	tarDir=$(tar -tf $javaTgz | head -n 1)
# 	tarDir=${tarDir%/}
# 	destFolder=$(basename $javaTgz | sed 's/\.tar\.gz//g' | sed "s/-$system//g")
# 	if [ -d "$javaDir/$destFolder" ]; then
# 		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
# 	else
# 		tar -zxf $javaTgz --transform "s/$tarDir/$destFolder/" -C $javaDir
# 		echo "$javaTgz extracted to $javaDir"
# 	fi
# done

for javaDmg in `ls -d $cloudDir/java/$system/*.dmg 2>/dev/null`; do
	mountDir=`hdiutil attach $javaDmg | awk 'FNR==2{print substr($0, index($0, $3))}'`;
	mainPkgFile=`find "${mountDir}" -name "*.pkg" 2>/dev/null | head -n 1`
	version=`echo $javaDmg | awk -F- '{print $(NF-2)}'`
	majorVersion=`echo $version | awk -Fu '{print $1}'`
	patchVersion=`echo $version | awk -Fu '{print $2}'`
	if [ "$patchVersion" == "" ]; then
		destFolder=jdk-${majorVersion}-x64
	else
		destFolder=jdk-${majorVersion}_${patchVersion}-x64
	fi
	if [ -d "$javaDir/$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		rm -rf /tmp/$destFolder
		rm -rf /tmp/$destFolder-unzipped
		pkgutil --expand "$mainPkgFile" /tmp/$destFolder
		jdkPkgFile=`find "/tmp/$destFolder" -name "jdk*.pkg" 2>/dev/null | head -n 1`
		payloadFile="${jdkPkgFile}/Payload"
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
	actualJavaVersion=$($specJava/bin/java -version 2>&1 | grep -i version | awk '{print $3}' | tr -d '"')

	major=`echo $expectedJavaVersion | awk -F_ '{print $1}'`
	patch=`echo $expectedJavaVersion | awk -F_ '{print $2}'`
	if [[ "$actualJavaVersion" =~ [0-9]+\.[0-9]+\.[0-9]+_[0-9]+ ]]; then
		expectedJavaVersion="1.$major.0_$patch"
	elif [[ "$actualJavaVersion" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
		expectedJavaVersion="$major.0.$patch"
	fi

	if [[ $actualJavaVersion == "$expectedJavaVersion" ]]; then
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
createVariables1 java JAVA "awk -F- '{print \$(NF-1)}' | awk -F_ '{print \$1}'"
