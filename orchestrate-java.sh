#!/usr/bin/env bash
# copy java to pf
javaDir=$pfDir/java
makeDir $javaDir


function calculateDestFolderName {
  destFolder=`echo $1 | sed 's/\.bin//g' | sed 's/\.tar\.gz//g' | sed 's/j2sdk/jdk/g' | sed 's/amd64/x64/g' | sed "s/-$system//g"`
  echo $destFolder
}

if [ "$system" == "linux" ] && [ `askYN "Configure Java from bin" "n"` == "y" ]; then

  currentDir=`pwd`
  for javaBinPath in `ls -d $cloudDir/java/$system-bin/*bin 2>/dev/null`; do

    javaBin=`basename $javaBinPath`
    proceed=`askYN "Configure $javaBin" "n"`

    if [ "$proceed" == "n" ]; then
      continue
    fi

    destDir=`calculateDestFolderName $javaBin`
    version=`echo $destDir | awk -F- '{print $2}'`

    if [[ "$version" =~ [0-9]+_[0-9]+_[0-9]+_[0-9]+ ]]; then
      major=`echo $version | awk -F_ '{print $2}'`
      minor=`echo $version | awk -F_ '{print $3}'`
      patch=`echo $version | awk -F_ '{print $4}'`
    elif [[ "$version" =~ [0-9]+u[0-9]+ ]]; then
      major=`echo $version | awk -Fu '{print $1}'`
      minor="0"
      patch=`echo $version | awk -Fu '{print $2}'`
    fi

    if [[ "$minor" == "0" ]]; then
      destDir=`echo $destDir | sed "s/$version/${major}u${patch}/g"`
    else
      destDir=`echo $destDir | sed "s/$version/${major}.${minor}u${patch}/g"`
    fi

    if [ -d "$javaDir/$destDir" ]; then
      echo -e "${CYAN}Dir $destDir exists - skipping${NC}"
      continue
    fi

    rm -rf /tmp/$javaBin
    cp $javaBinPath /tmp/$javaBin
    chmod u+x /tmp/$javaBin
    workingDir="/tmp/$destDir"
    rm -rf $workingDir
    mkdir $workingDir
    cd $workingDir
    /tmp/$javaBin
    javaFile=`find "$workingDir" -name "java" 2>/dev/null | head -n 1`

    if [ -f "$javaFile" ]; then
      dirName=`ls $workingDir`
      mkdir $javaDir/$destDir
      cp -r $workingDir/$dirName/* $javaDir/$destDir/
    else
        echo -e "${RED}$workingDir does not contain java${NC}"
    fi
  done
  cd $currentDir
fi

for javaTgzPath in `ls -d $cloudDir/java/$system/*.tar.gz 2>/dev/null`; do
  tarDir=`tar -tf $javaTgzPath | head -n 1 | awk -F/ '{print $1}'`
  tarDir=${tarDir%/}
  javaTgz=`basename $javaTgzPath`
  destFolder=`calculateDestFolderName $javaTgz`
  if [ -d "$javaDir/$destFolder" ]; then
    echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
  else
    tar -zxf $javaTgzPath --transform "s/$tarDir/$destFolder/" -C $javaDir
    echo "$javaTgzPath extracted to $javaDir"
  fi
done

for javaDmg in `ls -d $cloudDir/java/$system/*.dmg 2>/dev/null`; do
  mountDir=`hdiutil attach $javaDmg | awk 'FNR==2{print substr($0, index($0, $3))}'`;
  mainPkgFile=`find "${mountDir}" -name "*.pkg" 2>/dev/null | head -n 1`
  version=`echo $javaDmg | awk -F- '{print $(NF-2)}'`
  majorVersion=`echo $version | awk -Fu '{print $1}'`
  patchVersion=`echo $version | awk -Fu '{print $2}'`
  if [ "$patchVersion" == "" ]; then
    destFolder=jdk-${majorVersion}-x64
  else
    destFolder=jdk-${majorVersion}u${patchVersion}-x64
  fi
  if [ -d "$javaDir/$destFolder" ]; then
    echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
  else
    rm -rf /tmp/$destFolder
    rm -rf /tmp/$destFolder-unzipped
    pkgutil --expand "$mainPkgFile" /tmp/$destFolder
    jdkPkgFile=`find "/tmp/$destFolder" -name "jdk*.pkg" 2>/dev/null | head -n 1`
    payloadFile="${jdkPkgFile}/Payload"
    mkdir /tmp/$destFolder-unzipped
    mkdir "$javaDir/$destFolder"
    tar -zxf $payloadFile -C /tmp/$destFolder-unzipped
    cp -R /tmp/$destFolder-unzipped/Contents/Home/* "$javaDir/$destFolder/"
  fi
done

#verify java
javaDir=$pfDir/java
for specJava in `ls -d $javaDir/jdk-*`; do
  echo -e "${CYAN}Verifying $specJava${NC}"
  # verify version
  javaOutput=`$specJava/bin/java -version 2>&1`
  actualJavaVersion=`echo $javaOutput | grep -i version | awk '{print $3}' | tr -d '"'`

  expectedJavaVersion=`echo $specJava | awk -F- '{print $(NF-1)}'`
  majorMinor=`echo $expectedJavaVersion | awk -Fu '{print $1}'`
  patch=`echo $expectedJavaVersion | awk -Fu '{print $2}'`
  major=`echo $majorMinor | awk -F. '{print $1}'`
  minor=`echo $majorMinor | awk -F. '{print $2}'`
  if [ "$minor" == "" ]; then
    minor="0"
  fi
  patch=`echo $expectedJavaVersion | awk -Fu '{print $2}'`
  if [[ "$actualJavaVersion" =~ [0-9]+\.[0-9]+\.[0-9]+_[0-9]+ ]]; then
    expectedJavaVersion="1.$major.${minor}_$patch"
  elif [[ "$actualJavaVersion" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
    expectedJavaVersion="$major.$minor.$patch"
  fi

  if [[ $actualJavaVersion == "$expectedJavaVersion" ]]; then
    echo -e "    ${GREEN}Java version is correct - $actualJavaVersion${NC}"
  else
    echo -e "    ${RED}Java version is not correct - expected: $expectedJavaVersion, got: $actualJavaVersion${NC}"
  fi
  #verify platform
  expectedPlatform=`echo $specJava | awk -F- '{print $NF}'`
  is64=`echo $javaOutput -version 2>&1 | grep -i "64-Bit"`
  actualPlatform="x64"
  if [ "$is64" == ""  ]; then
    actualPlatform="i586"
  fi
  if [ "$expectedPlatform" == "$actualPlatform" ]; then
    echo -e "    ${GREEN}Java platform is correct - $actualPlatform${NC}"
  else
    echo -e "    ${RED}Java platform is not correct - expected: $expectedPlatform, got: $actualPlatform${NC}"
  fi
done

#add java variables
createVariables2 java java "sed 's/jdk-//g' | sed 's/\.[0-9]*//g' | sed 's/u[0-9]*//g' | sed 's/-i586/.x32/g' | sed 's/-x64/.x64/g'"
