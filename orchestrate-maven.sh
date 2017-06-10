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

#add maven variables
maxVersion=0
echo "# maven" >> $varFile
for specMaven in `ls -d $mavenDir/*`; do
	mavenVersion=$(echo $specMaven | awk -F/ '{print $(NF)}' | sed 's/apache-maven-\(.*\)/\1/')
	major=$(echo $mavenVersion | cut -d'.' -f1)
	minor=$(echo $mavenVersion | cut -d'.' -f2)
	patch=$(echo $mavenVersion | cut -d'.' -f3)

	if [[ $major -gt $maxVersion ]]; then
		maxVersion=$major
	else
		sed -i /MVN${major}_HOME=/d $varFile
	fi
	echo "export MVN${major}_HOME=$specMaven" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
done;
echo "export MVN_HOME=\$MVN${maxVersion}_HOME" >> $varFile
echo "export PATH=\$MVN_HOME/bin:\$PATH" >> $varFile