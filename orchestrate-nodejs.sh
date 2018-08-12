#!/usr/bin/env bash
# copy node to pf
nodejsDir=$pfDir/nodejs
makeDir $nodejsDir

os=`echo $osname | awk '{print tolower($0)}'`
for nodejsTgz in `ls -d $cloudDir/nodejs/$system/*-$os-x64.tar.xz 2>/dev/null`; do
  archiveDir=$(tar -tf $nodejsTgz | head -n 1)
  archiveDir=${archiveDir%/}
  if [ -d "$nodejsDir/$archiveDir" ]; then
    echo -e "${CYAN}Dir $archiveDir exists - skipping${NC}"
  else
#   tar xf $nodejsTgz --transform "s/$archiveDir/$destFolder/" -C $nodejsDir
    tar xf $nodejsTgz -C $nodejsDir
    echo "$nodejsTgz extracted to $nodejsDir"
  fi
done

unzipFamily nodejs

#verify nodejs
for specNodejs in `ls -d $nodejsDir/* 2>/dev/null`; do
  # verify version
  expectedNodejsVersion=$(echo $specNodejs | awk -F- '{print $(NF-2)}')
  if [ -d "$specNodejs/bin" ]; then
    actualNodejsVersion=$($specNodejs/bin/node --version)
  else
    actualNodejsVersion=$($specNodejs/node --version)
  fi
  if [[ "$actualNodejsVersion" == "$expectedNodejsVersion" ]]; then
    echo -e "${GREEN}Nodejs version is correct - $actualNodejsVersion${NC}"
  else
    echo -e "${RED}Nodejs version is not correct - expected: $expectedNodejsVersion, got: $actualNodejsVersion${NC}"
  fi
done

createVariables2 nodejs nodejs

