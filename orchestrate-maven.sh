#!/usr/bin/env bash

# copy maven to pf
mavenDir=$pfDir/apache-maven
makeDir $mavenDir
for mavenTgz in `ls -d $cloudDir/maven/*.tar.gz`; do
	tarDir=$(tar tzf $mavenTgz | sed -e 's|/.*||' | uniq)
	tarDir=${tarDir%/}
	destFolder=$mavenDir/$tarDir
	if [ -d "$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		tar -zxf $mavenTgz -C $mavenDir
		echo "$mavenTgz extracted to $mavenDir"
	fi
done

. $varFile

#verify maven
for specMaven in `ls -d $mavenDir/*`; do
	# verify version
	expectedMavenVersion=$(echo $specMaven | awk -F/ '{print $(NF)}' | sed 's/apache-maven-\(.*\)/\1/')
	actualMavenVersion=$($specMaven/bin/mvn --version 2>&1 | head -n 1 | awk '{print $3}')
	if [[ $actualMavenVersion == "$expectedMavenVersion" ]]; then
		echo -e "${GREEN}Maven version is correct - $actualMavenVersion${NC}"
	else
		echo -e "${RED}Maven version is not correct - expected: $expectedMavenVersion, got: $actualMavenVersion${NC}"
	fi
done

# verify maven with appropriate Java version https://maven.apache.org/docs/history.html
# <= 2.1.0 = 4
# <= 3.1.1 = 5
# <= 3.2.5 = 6
# <= 3.5.0 = 7
currentJavaVersion=$JAVA_HOME
for specMaven in `ls -d $mavenDir/*`; do
	mavenVersion=$(echo $specMaven | awk -F/ '{print $(NF)}' | sed 's/apache-maven-\(.*\)/\1/')
	major=$(echo $mavenVersion | cut -d'.' -f1)
	minor=$(echo $mavenVersion | cut -d'.' -f2)
	patch=$(echo $mavenVersion | cut -d'.' -f3)
	version=$((10000 * $major + 100 * $minor + $patch))

	if (( version <= 20100 )) && [ ! -z $JAVA4_x32_HOME ]; then
		JAVA_HOME=$JAVA4_x32_HOME
	elif (( version <= 30101 )) && [ ! -z $JAVA5_x64_HOME ]; then
		JAVA_HOME=$JAVA5_x64_HOME
	elif (( version <= 30205 )) && [ ! -z $JAVA6_x64_HOME ]; then
		JAVA_HOME=$JAVA6_x64_HOME
	else
		JAVA_HOME=$JAVA7_x64_HOME
	fi

	# verify version with specific java version
	expectedMavenVersion=$(echo $specMaven | awk -F/ '{print $(NF)}' | sed 's/apache-maven-\(.*\)/\1/')
	actualMavenVersion=$($specMaven/bin/mvn --version 2>&1 | head -n 1 | awk '{print $3}')
	if [[ $actualMavenVersion == "$expectedMavenVersion" ]]; then
		echo -e "${GREEN}Maven version $expectedMavenVersion is working with $JAVA_HOME${NC}"
	else
		echo -e "${RED}Maven version $expectedMavenVersion is not working with $JAVA_HOME${NC}"
	fi
done
JAVA_HOME=$currentJavaVersion

createVariables2 apache-maven mvn "sed 's/apache-maven-//g'"
echo "export MAVEN_OPTS=\"-Dmaven.wagon.http.ssl.insecure=true\"" >> $varFile
