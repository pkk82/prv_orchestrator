#!/usr/bin/env bash
# copy java to pf
javaDir=$pfDir/java
makeDir $javaDir


if [[ "$system" == "linux" ]] && [[ `askYN "Configure Java from bin" "n"` == "y" ]]; then

  currentDir=`pwd`
  for javaBinPath in `ls -d $cloudDir/java/$system-bin/*bin 2>/dev/null`; do

    javaBin=`basename $javaBinPath`
    proceed=`askYN "Configure $javaBin" "n"`

    if [[ "$proceed" == "n" ]]; then
      continue
    fi

    destDir=`echo $javaBinPath | awk -F/ '{print $NF}' | sed "s/-$system//g" | sed 's/.bin//g'`

    if [[ -d "$javaDir/$destDir" ]]; then
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
    javaFile=`find "$workingDir" -type f -name "java" 2>/dev/null | head -n 1`

    if [[ -f "$javaFile" ]]; then
      dirName=`ls $workingDir`
      mkdir $javaDir/$destDir
      cp -r $workingDir/$dirName/* $javaDir/$destDir/
    else
        echo -e "${RED}$workingDir does not contain java${NC}"
    fi
  done
  cd $currentDir
fi


untarFamily java "" "sed 's/-$system//g' | sed 's/.tar.gz//g'"
unzipFamily java

for javaDmg in `ls -d $cloudDir/java/$system/*.dmg 2>/dev/null`; do
  mountDir=`hdiutil attach $javaDmg | awk 'FNR==2{print substr($0, index($0, $3))}'`;
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
    tar -zxf $payloadFile -C /tmp/$destFolder-unzipped
    cp -R /tmp/$destFolder-unzipped/Contents/Home/* "$javaDir/$destFolder/"
  fi
done

verify java \
  "awk -F- '{print \$(NF-1)}' | sed 's/^1\.//g' | sed 's/^/\"/g' | sed 's/$/\"/g'" \
  "bin/java -version 2>&1 | grep -i 'version' | awk '{print \$3}' | sed 's/\+/u/g' | sed 's/1\.//g' | sed 's/\.0//g' | sed 's/_/u/g'" "version"

verify java \
  "awk -F- '{print \$NF}'" \
  "bin/java -version 2>&1 | (grep -i '64-Bit' || echo 'i586') | sed s/.*64-Bit.*/x64/g"  "platform"

createVariables2 java java "sed 's/jdk-//g' | sed 's/1\.//g' | sed 's/\.[0-9]*//g' | sed 's/u[0-9]*//g' | sed 's/-i586/.x32/g' | sed 's/-x64/.x64/g'"
