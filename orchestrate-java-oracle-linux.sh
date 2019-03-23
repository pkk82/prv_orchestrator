#!/usr/bin/env bash

if [[ "$system" == "linux" ]]; then

  javaDir=$pfDir/java-oracle
  makeDir $javaDir
  if [[ `askYN "Configure Java from bin" "n"` == "y" ]]; then

    currentDir=`pwd`
    for javaBinPath in `ls -d $cloudDir/java-oracle/$system-bin/*bin 2>/dev/null`; do

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

  untarFamily java-oracle "" "sed 's/-$system//g' | sed 's/.tar.gz//g'"
fi



