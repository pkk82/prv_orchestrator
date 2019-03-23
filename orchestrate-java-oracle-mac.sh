#!/usr/bin/env bash


if [[ "$system" == "mac" ]]; then

  javaDir="$pfDir/java-oracle"
  makeDir "$javaDir"

  for javaDmg in `ls -d $cloudDir/java-oracle/$system/*.dmg 2>/dev/null`; do
    mountDir=`hdiutil attach $javaDmg | grep 'Apple_HFS' | awk '{print substr($0, index($0, $3))}'`;
    mainPkgFile=`find "${mountDir}" -name "*.pkg" 2>/dev/null | head -n 1`
    version=`echo $javaDmg | awk -F- '{print $(NF-2)}'`
    majorVersion=`echo $version | awk -Fu '{print $1}'`
    patchVersion=`echo $version | awk -Fu '{print $2}'`
    if [[ "$patchVersion" == "" ]]; then
      destFolder=jdk-${majorVersion}-x64
    else
      destFolder=jdk-${majorVersion}u${patchVersion}-x64
    fi
    if [[ -d "$javaDir/$destFolder" ]]; then
      echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
    else
      rm -rf /tmp/$destFolder
      rm -rf /tmp/$destFolder-unzipped
      pkgutil --expand "$mainPkgFile" /tmp/$destFolder
      jdkPkgFile=`find "/tmp/$destFolder" -name "jdk*.pkg" 2>/dev/null | head -n 1`
      payloadFile="${jdkPkgFile}/Payload"
      mkdir /tmp/$destFolder-unzipped
      mkdir "$javaDir/$destFolder"
      tar -zxf "$payloadFile" -C "/tmp/$destFolder-unzipped"
      cp -R /tmp/$destFolder-unzipped/Contents/Home/* "$javaDir/$destFolder/"
    fi
    hdiutil detach "$mountDir"
  done
fi
