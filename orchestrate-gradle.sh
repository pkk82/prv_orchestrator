#!/usr/bin/env bash

# copy gradle to pf
gradleDir=$pfDir/gradle
makeDir $gradleDir
for gradleZip in `ls -d $cloudDir/gradle/*.zip`; do
	zipDir=$(unzip -l $gradleZip | awk '{print $4}' | grep '/' | sed -e 's|/.*||' | uniq)
	zipDir=${zipDir%/}
	destFolder=$gradleDir/$zipDir
	if [ -d "$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		unzip -q $gradleZip -d $gradleDir
		echo "$gradleZip extracted to $gradleDir"
	fi
done

. $varFile

#verify gradle
for specGradle in `ls -d $gradleDir/*`; do
	# verify version
	expectedGradleVersion=$(echo $specGradle | awk -F/ '{print $(NF)}' | sed 's/gradle-\(.*\)/\1/')
	actualGradleVersion=$($specGradle/bin/gradle --version | grep Gradle | awk '{print $2}')
	if [[ $actualGradleVersion == "$expectedGradleVersion" ]]; then
		echo -e "${GREEN}Gradle version is correct - $actualGradleVersion${NC}"
	else
		echo -e "${RED}Gradle version is not correct - expected: $expectedGradleVersion, got: $actualGradleVersion${NC}"
	fi
done


## verify gradle with appropriate Java version
currentJavaVersion=$JAVA_HOME
for specGradle in `ls -d $gradleDir/*`; do
	gradleVersion=$(echo $specGradle | awk -F/ '{print $(NF)}' | sed 's/gradle-\(.*\)/\1/')
	major=$(echo $gradleVersion | cut -d'.' -f1)

	if (( major <= 1 )) && [ ! -z $JAVA5_HOME ]; then
		JAVA_HOME=$JAVA5_HOME
	elif (( major <= 2 )) && [ ! -z $JAVA6_HOME ]; then
		JAVA_HOME=$JAVA6_HOME
	elif (( major <= 3 )) && [ ! -z $JAVA7_HOME ]; then
		JAVA_HOME=$JAVA7_HOME
	else
		JAVA_HOME=$JAVA7_HOME
	fi

	# verify version with specific java version
	expectedGradleVersion=$(echo $specGradle | awk -F/ '{print $(NF)}' | sed 's/gradle-\(.*\)/\1/')
	actualGradleVersion=$($specGradle/bin/gradle --version | grep Gradle | awk '{print $2}')
	if [[ $actualGradleVersion == "$expectedGradleVersion" ]]; then
		echo -e "${GREEN}Gradle version $expectedGradleVersion is working with $JAVA_HOME${NC}"
	else
		echo -e "${RED}Gradle version $expectedGradleVersion is not working with $JAVA_HOME${NC}"
	fi
done
JAVA_HOME=$currentJavaVersion


#add gradle variables
maxVersion=0
echo "# gradle" >> $varFile
for specGradle in `ls -d $gradleDir/*`; do
	gradleVersion=$(echo $specGradle | awk -F/ '{print $(NF)}' | sed 's/gradle-\(.*\)/\1/')
	major=$(echo $gradleVersion | cut -d'.' -f1)

	if [[ $major -gt $maxVersion ]]; then
		maxVersion=$major
	else
		sed -i /GRADLE${major}_HOME=/d $varFile
	fi
	echo "export GRADLE${major}_HOME=$specGradle" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
done;
echo "export GRADLE_HOME=\$GRADLE${maxVersion}_HOME" >> $varFile
echo "export PATH=\$GRADLE_HOME/bin:\$PATH" >> $varFile