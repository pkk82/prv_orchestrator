#!/usr/bin/env bash

dotM2=$HOME/.m2
mkdir -p $dotM2

toolchains=$dotM2/toolchains.xml

rm -rf $toolchains

cat >> $toolchains << EOL
<?xml version="1.0" encoding="UTF8"?>
<toolchains>
EOL

javaDir=$pfDir/java
for specJava in `ls -d $javaDir/*`; do

	javaVersion=$(echo $specJava | awk -F- '{print $(NF-1)}' | tr 'u' '_')
	platform=$(echo $specJava | awk -F- '{print $NF}')
	major=$(echo $javaVersion | cut -d'.' -f1)
	minor=$(echo $javaVersion | cut -d'.' -f2)

	if [ "$system" == "windows" ]; then
		finalPath=$(echo $specJava | sed 's|/c|c:|g' | sed 's|/|\\|g')
	else
		finalPath=$specJava
	fi


cat >> $toolchains << EOL
	<toolchain>
		<type>jdk</type>
		<provides>
			<version>${major}.${minor}</version>
			<vendor>sun</vendor>
			<platform>$platform</platform>
		</provides>
		<configuration>
			<jdkHome>$finalPath</jdkHome>
		</configuration>
	</toolchain>
EOL

done

cat >> $toolchains << EOL
</toolchains>
EOL

echo -e "${GREEN}$toolchains configured${NC}"