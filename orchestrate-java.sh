#!/usr/bin/env bash
# copy java to pf
javaDir=$pfDir/java
makeDir $javaDir
for javaTgz in `ls -d $cloudDir/$system/java/*.tar.gz`; do
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

#verify java
javaDir=$pfDir/java
for specJava in `ls -d $javaDir/*`; do
	# verify version
	expectedJavaVersion=$(echo $specJava | awk -F- '{print $(NF-1)}' | tr 'u' '_')
	actualJavaVersion=$($specJava/bin/java -version 2>&1 | grep -i version)
	if [[ $actualJavaVersion == *"$expectedJavaVersion"* ]]; then
		echo -e "${GREEN}Java version is correct - $actualJavaVersion${NC}"
	else
		echo -e "${RED}Java version is not correct - expected: $expectedJavaVersion, got: $actualJavaVersion${NC}"
	fi
	#verify platform
	expectedPlatform=$(echo $specJava | awk -F- '{print $NF}')
	is64=$($specJava/bin/java -version 2>&1 | grep -i "64-Bit")
	actualPlatform="x64"
	if [ "$is64" == ""  ]; then
		actualPlatform="i586"
	fi
	if [ "$expectedPlatform" == "$actualPlatform" ]; then
		echo -e "${GREEN}Java platform is correct - $actualPlatform${NC}" 
	else
		echo -e "${RED}Java platform is not correct - expected: $expectedPlatform, got: $actualPlatform${NC}" 
	fi
done

#add java variables
maxVersion=0
echo "# java" >> $varFile
for specJava in `ls -d $javaDir/*`; do
	expectedJavaVersion=$(echo $specJava | awk -F- '{print $(NF-1)}' | cut -d'.' -f2)
	if [[ $expectedJavaVersion -gt $maxVersion ]]; then
		maxVersion=$expectedJavaVersion
	else
		sed -i /JAVA${expectedJavaVersion}_HOME=/d $varFile
	fi
	echo "export JAVA${expectedJavaVersion}_HOME=$specJava" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
done;
echo "export JAVA_HOME=\$JAVA${maxVersion}_HOME" >> $varFile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> $varFile



