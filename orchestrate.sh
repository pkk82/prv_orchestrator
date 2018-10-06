#!/usr/bin/env bash
NC='\033[0m'; YELLOW='\033[0;33m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; RED='\033[0;31m'

function actionMessage {
  echo -e "${BLUE}$1${NC}"
}

function queryMessage {
  echo -e "${CYAN}$1${NC}: "
}

function queryMessageWithDefault {
  echo -e "${CYAN}$1${NC} ($2): "
}

function positiveMessage {
  echo -e "${GREEN}$1${NC}"
}

function warningMessage {
  echo -e "${YELLOW}$1${NC}"
}


function askPassword {
  read -s -p "$(queryMessage "$1")" password
  echo "$password"
}

function askWithDefault {
  read -p "$(queryMessageWithDefault "$1" "$2")" answer
  local answer=${answer:-$2}
  echo "$answer"
}

function askYN {
  read -p "$(queryMessageWithDefault "$1 [y/n]" "$2")" answer
  local answer=${answer:-$2}
  echo "$answer"
}

function makeDir {
  if [ -d $1 ]; then
    echo -e "${CYAN}Dir $1 already exists${NC}"
  elif mkdir -p $1; then
    echo -e "${GREEN}Dir $1 created${NC}"
  else
    echo -e "${RED}Dir $1 not created${NC}"
    exit
  fi
}

function unzipFamily {
  familyDir=$pfDir/$1
  makeDir $familyDir
  for zip in `ls $cloudDir/$1/*.zip $cloudDir/$1/$system/*.zip 2>/dev/null`; do
    dirInZip=$(unzip -l $zip | awk '{print $4}' | grep '/' | sed -e 's|/.*||' | uniq)
    dirInZip=${zipDir%/}
    destDir=$familyDir/$dirInZip
    if [ "$2" != "" ]; then
      destDir=`eval "echo $destDir | $2"`
    fi
    if [ -d "$destDir" ]; then
      echo -e "${CYAN}Dir $destDir exists - skipping${NC}"
    else
      unzip -q $zip -d $familyDir
      if [ "$2" != "" ]; then
        mv $familyDir/$dirInZip $destDir
      fi
      echo "$dirInZip extracted to $familyDir as $destDir"
    fi
  done
}

function untarFamily {
  familyDir=$pfDir/$1
  makeDir $familyDir
  for archive in `ls $cloudDir/$1/*.tar.gz $cloudDir/$1/$system/*.tar.gz $cloudDir/$1/*.tar.xz $cloudDir/$1/$system/*.tar.xz 2>/dev/null`; do
    dirInArch=`tar -tf $archive | head -n 1`
    dirInArch=${dirInArch%/}
    destDir=$familyDir/$dirInArch
    if [ "$2" != "" ]; then
      destDir=`eval "echo $destDir | $2"`
    fi
    if [ -d "$destDir" ]; then
      echo -e "${CYAN}Dir $destDir exists - skipping${NC}"
    else
      tar xf $archive -C $familyDir
      if [ "$2" != "" ]; then
        mv $familyDir/$dirInArch $destDir
      fi
      echo "$dirInArch extracted to $familyDir as $destDir"
    fi
  done
}




function copyFamilyAsFiles {
  familyDir=$pfDir/$1
  makeDir $familyDir
  for file in `ls -d $cloudDir/$1/$1*`; do
    fileName=$(echo $file | awk -F/ '{print $(NF)}')
    destFile=$familyDir/$fileName
    if [ -f "$destFile" ]; then
      echo -e "${CYAN}File $destFile exists - skipping${NC}"
    else
      cp $file $familyDir
      echo "$fileName copied to $familyDir"
    fi
  done
}

function copyFamilyAsDirs {
  familyDir=$pfDir/$1
  makeDir $familyDir
  for dir in `ls -d $cloudDir/$1/$1*`; do
    dirName=$(echo $dir | awk -F/ '{print $(NF)}')
    destDir=$familyDir/$dirName
    if [ -d "$destDir" ]; then
      echo -e "${CYAN}Directory $destDir exists - skipping${NC}"
    else
      cp -R $dir ${familyDir%/}
      echo -e "${GREEN}$destDir copied to $familyDir${NC}"
    fi
  done
}

function verify {
  familyDir=$pfDir/$1
  for spec in `ls -d $familyDir/*`; do
    expectedVersion=$(echo $spec | awk -F/ '{print $(NF)}' | sed "s/$1-\(.*\)/\1/")
    minor=$(echo $expectedVersion | cut -d. -f2)
    if [ ! -z ${3+x} ]; then
      eval $3
    fi
    actualVersion=$(eval $spec/$2)
    if [[ $actualVersion == "$expectedVersion" ]]; then
      echo -e "${GREEN}$1 version is correct - $actualVersion${NC}"
    else
      echo -e "${RED}$1 version is not correct - expected: $expectedVersion, got: $actualVersion${NC}"
    fi
  done
}

function createVariables2 {
  maxVersionToCompare=0
  maxVersion=""
  familyDir=$pfDir/$1
  upperName=`echo $2 | awk '{print toupper($0)}'`
  echo "# $1" >> $varFile
  for specPath in `ls -d $familyDir/* 2>/dev/null`; do
    spec=`basename $specPath`
    if [ "$3" == "" ]; then
      version=$(echo $spec | awk -F- '{print $NF}')
    else
      version=$(eval " echo $spec | $3")
    fi
    majorVersion=$(echo $version | cut -d. -f1)
    minorVersion=$(echo $version | cut -d. -f2)
    version=${majorVersion}_${minorVersion}
    minorVersionNumber=`echo $minorVersion | sed s/[a-z]*//g`
    versionToCompare=$((10000 * $majorVersion + $minorVersionNumber))
    if [[ $versionToCompare -gt $maxVersionToCompare ]]; then
      maxVersionToCompare=$versionToCompare
      maxVersion=$version
    fi
    specHomeVar="${upperName}${version}_HOME"
    homeVar="${upperName}_HOME"
    echo "export $specHomeVar=$specPath" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
    if [ -d "$specPath/bin" ]; then
      echo "alias use-$2-${version}='export $homeVar=\$$specHomeVar; export PATH=\$$homeVar/bin:\$PATH'" >> $aliasesFile
    else
      echo "alias use-$2-${version}='export $homeVar=\$$specHomeVar; export PATH=\$$homeVar:\$PATH'" >> $aliasesFile
    fi
  done;

  if [[ "$maxVersion" != "" ]]; then
    echo "export $homeVar=\$$specHomeVar" >> $varFile
    if [ -d "$specPath/bin" ]; then
      echo "export PATH=\$$homeVar/bin:\$PATH" >> $varFile
    else
      echo "export PATH=\$$homeVar:\$PATH" >> $varFile
    fi
  fi
  . $varFile
}

function backslashWhenWindows {
  if [ "$system" == "windows" ]; then
    finalPath=$(echo "$1" | sed 's|/c|c:|g' | sed 's|/|\\|g')
  else
    finalPath="$1"
  fi
  echo "$finalPath"
}

function driveNotationWhenWindows {
  if [ "$system" == "windows" ]; then
    finalPath=$(echo "$1" | sed 's|/c|c:|g')
  else
    finalPath="$1"
  fi
  echo "$finalPath"
}

# calculate system
osname=`uname`
if [ "$USERPROFILE" != "" ]; then
  system="windows"
  mainDir="/c"
  sedBackupSuffix=""
elif [[ "$osname" == "Linux" ]]; then
  system="linux"
  mainDir=$HOME
  sedBackupSuffix=""
elif [[ "$osname" == "Darwin" ]]; then
  system="mac"
  mainDir=$HOME
  sedBackupSuffix=".bak"
fi
echo -e "${GREEN}Detected system: $system${NC}"

# calculate cloud dir
cloudDir=`askWithDefault "Enter path to software directory" "$HOME/vd/Dropbox/software"`

# create pf dir

useStandardPfDirDefault="y"
echo -e -n "${CYAN}Use ${mainDir}/pf directory [y/n]${NC} ($useStandardPfDirDefault): "
read useStandardPfDir
useStandardPfDir=${useStandardPfDir:-$useStandardPfDirDefault}

if [ "$useStandardPfDir" == "y" ]; then
  pfDir=${mainDir}/pf
else
  existingDirs=$(ls -d $mainDir/pf*)
  echo "Existing pf directories:"
  echo "$existingDirs"
  pfDirDefault="$mainDir/pf-$(date '+%Y%m%d-%H%M')"
  echo -e -n "${CYAN}Enter path to program files directory${NC} ($pfDirDefault): "
  read pfDir
  pfDir=${pfDir:-$pfDirDefault}
fi
makeDir $pfDir

rcFile="$HOME/.bashrc"
aliasesFile="$HOME/.bash_aliases"
varFile="$HOME/.bash_variables"
functionsFile="$HOME/.bash_functions"
echo "export CLOUD_SOFTWARE_DIR=$cloudDir" > $varFile
echo "export PF_DIR=$pfDir" >> $varFile

. orchestrate-aliases.sh
. orchestrate-java.sh
. orchestrate-java-jce-policy.sh
. orchestrate-dtool.sh
. orchestrate-ant.sh
. orchestrate-kotlin.sh
. orchestrate-maven.sh
. orchestrate-maven-settings.sh
. orchestrate-maven-toolchains.sh
. orchestrate-gradle.sh
. orchestrate-scala.sh
. orchestrate-clojure.sh
. orchestrate-leiningen.sh
. orchestrate-kafka.sh
. orchestrate-nodejs.sh
. orchestrate-vscode.sh
. orchestrate-intellij-idea.sh
. orchestrate-atom.sh
. orchestrate-password.sh
. orchestrate-backups-script.sh
. orchestrate-postgres.sh
. orchestrate-functions.sh
. orchestrate-bashrc.sh
