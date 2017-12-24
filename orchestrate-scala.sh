#!/usr/bin/env bash

# copy scala to pf
scalaDir=$pfDir/scala
makeDir $scalaDir
for scalaTgz in `ls -d $cloudDir/scala/*.tgz $cloudDir/scala/*.tar.gz`; do
	tarDir=$(tar -tf $scalaTgz | head -n 1)
	tarDir=${tarDir%/}
	destFolder=$scalaDir/$tarDir
	if [ -d "$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
		tar -zxf $scalaTgz -C $scalaDir
		echo "$scalaTgz extracted to $scalaDir"
	fi
done

#verify scala
for specScala in `ls -d $scalaDir/*`; do
	# verify version
	expectedScalaVersion=$(echo $specScala | awk -F/ '{print $(NF)}' | sed 's/scala-\(.*\)/\1/')
	actualScalaVersion=$($specScala/bin/scala -version 2>&1 | awk '{print $5}')
	if [[ $actualScalaVersion == "$expectedScalaVersion" ]]; then
		echo -e "${GREEN}Scala version is correct - $actualScalaVersion${NC}"
	else
		echo -e "${RED}Scala version is not correct - expected: $expectedScalaVersion, got: $actualScalaVersion${NC}"
	fi
done


#add scala variables
maxVersion=0
echo "# scala" >> $varFile
for specScala in `ls -d $scalaDir/*`; do
	expectedScalaVersion=$(echo $specScala | awk -F/ '{print $(NF)}' | sed 's/.final//' | awk -F. '{print $(NF-1)}')
	if [[ $expectedScalaVersion -gt $maxVersion ]]; then
		maxVersion=$expectedScalaVersion
	else
		sed -i $sedBackupSuffix /SCALA${expectedScalaVersion}_HOME=/d $varFile
	fi
	echo "export SCALA${expectedScalaVersion}_HOME=$specScala" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
done;
echo "export SCALA_HOME=\$SCALA${maxVersion}_HOME" >> $varFile
echo "export PATH=\$SCALA_HOME/bin:\$PATH" >> $varFile


