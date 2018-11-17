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

for familyDir in `ls -d $pfDir/java*`; do
  vendor=`echo $familyDir | awk -F/ '{print $NF}' | awk -F- '{print $2}'`
  if [[ $vendor == "" ]]; then
    vendor="oracle"
  fi

  for specJava in `ls -d $familyDir/*`; do

    javaVersion=`echo $specJava | awk -F- '{print $(NF-1)}' | cut -d'u' -f1`
    platform=`echo $specJava | awk -F- '{print $NF}'`
    finalPath=`backslashWhenWindows $specJava`

    cat >> $toolchains << EOL
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>${javaVersion}</version>
            <vendor>$vendor</vendor>
            <platform>$platform</platform>
        </provides>
        <configuration>
            <jdkHome>$finalPath</jdkHome>
        </configuration>
    </toolchain>
EOL

  done

done



cat >> $toolchains << EOL
</toolchains>
EOL

echo -e "${GREEN}$toolchains configured${NC}"
