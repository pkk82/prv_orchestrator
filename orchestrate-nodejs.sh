#!/usr/bin/env bash
# copy node to pf
nodejsDir=$pfDir/nodejs
makeDir $nodejsDir

os=`echo $osname | awk '{print tolower($0)}'`
for nodejsTgz in `ls -d $cloudDir/nodejs/$system/*-$os-x64.* 2>/dev/null`; do
	archiveDir=$(tar -tf $nodejsTgz | head -n 1)
	archiveDir=${archiveDir%/}
	destFolder=$(echo $archiveDir | sed 's/node-v/nodejs-/g' | sed "s/-$os-x64//g")
	echo $destFolder
	if [ -d "$nodejsDir/$destFolder" ]; then
		echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
	else
#		tar xf $nodejsTgz --transform "s/$archiveDir/$destFolder/" -C $nodejsDir
		tar xf $nodejsTgz -C $nodejsDir
		mv $nodejsDir/$archiveDir $nodejsDir/$destFolder
		echo "$nodejsTgz extracted to $nodejsDir"
	fi
done

#verify nodejs
for specNodejs in `ls -d $nodejsDir/* 2>/dev/null`; do
	# verify version
	expectedNodejsVersion=$(echo $specNodejs | awk -F- '{print $NF}')
	actualNodejsVersion=$($specNodejs/bin/node --version)
	if [[ "$actualNodejsVersion" == "v$expectedNodejsVersion" ]]; then
		echo -e "${GREEN}Nodejs version is correct - $actualNodejsVersion${NC}"
	else
		echo -e "${RED}Nodejs version is not correct - expected: $expectedNodejsVersion, got: $actualNodejsVersion${NC}"
	fi
done


#add nodejs variables
maxVersionToCompare=0
maxVersion=""
echo "# nodejs" >> $varFile
for specNodejs in `ls -d $nodejsDir/* 2>/dev/null`; do
	version=$(echo $specNodejs | awk -F- '{print $NF}')
	majorVersion=$(echo $version | cut -d. -f1)
	minorVersion=$(echo $version | cut -d. -f2)
	version=${majorVersion}_${minorVersion}
	versionToCompare=$((10000 * $majorVersion + $minorVersion))
	if [[ $versionToCompare -gt $maxVersionToCompare ]]; then
		maxVersionToCompare=$versionToCompare
		maxVersion=$version
	fi
	echo "export NODEJS${version}_HOME=$specNodejs" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
	echo "alias use-nodejs-${version}='export NODEJS_HOME=\$NODEJS${version}_HOME; export PATH=\$NODEJS_HOME/bin:\$PATH'" >> $aliasesFile
done;

if [[ "$maxVersion" != "" ]]; then
echo "export NODEJS_HOME=\$NODEJS${maxVersion}_HOME" >> $varFile
echo "export PATH=\$NODEJS_HOME/bin:\$PATH" >> $varFile
fi

