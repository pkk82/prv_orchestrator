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

function askWithDefaults {
  defValue=$2
  if [[ "$2" == "" ]] && [[ $3 != "" ]]; then
    defValue=$3
  fi
  read -p "$(queryMessageWithDefault "$1" "$defValue")" answer
  local answer=${answer:-$defValue}
  echo "$answer"
}

function askYN {
  read -p "$(queryMessageWithDefault "$1 [y/n]" "$2")" answer
  local answer=${answer:-$2}
  echo "$answer"
}

function makeDir {
  if [[ -d $1 ]]; then
    echo -e "${CYAN}Dir $1 already exists${NC}"
  elif mkdir -p $1; then
    echo -e "${GREEN}Dir $1 created${NC}"
  else
    echo -e "${RED}Dir $1 not created${NC}"
    exit
  fi
}

# $1 - family name
# $2 - dirInArch transformation
# $3 - archive name transformation
function unzipFamily {
  archives=`ls $cloudDir/$1/*.zip $cloudDir/$1/$system/*.zip 2>/dev/null`
  if [[ "$archives" != "" ]]; then
    familyDir=$pfDir/$1
    makeDir $familyDir
    for zip in $archives; do
      dirInZip=$(unzip -l $zip | awk '{print $4}' | grep '/' | sed -e 's|/.*||' | uniq)
      dirInZip=${dirInZip%/}
      zipName=`echo $zip | awk -F/ '{print $NF}'`
      destDir=$familyDir/$dirInZip
      if [[ "$2" != "" ]]; then
        destDir=$familyDir/$dirInZip
        destDir=`eval "echo $destDir | $2"`
      fi
      if [[ "$3" != "" ]]; then
        destDir=$familyDir/$zipName
        destDir=`eval "echo $destDir | $3"`
        destDir=`echo $destDir | sed 's/.zip//g'`
      fi
      if [[ -d "$destDir" ]]; then
        echo -e "${CYAN}Dir $destDir exists - skipping${NC}"
      else
        unzip -q $zip -d $familyDir
        if [[ "$2" != "" || "$3" != "" ]]; then
          mv $familyDir/$dirInZip $destDir
        fi
        echo "$dirInZip extracted to $familyDir as $destDir"
      fi
    done
  fi
}

# $1 - family name
# $2 - dirInArch transformation
# $3 - archive name transformation
function untarFamily {
  archives=`ls $cloudDir/$1/*.tar.gz $cloudDir/$1/$system/*.tar.gz $cloudDir/$1/*.tar.xz $cloudDir/$1/$system/*.tar.xz $cloudDir/$1/*.tgz $cloudDir/$1/$system/*.tgz 2>/dev/null`
  if [[ "$archives" != "" ]]; then
    familyDir=$pfDir/$1
    makeDir $familyDir
    for archive in $archives; do
      dirInArch=`tar -tf $archive | awk -F/ '{print $1}' | uniq | head -n 1`
      dirInArch=${dirInArch%/}
      archiveName=`echo $archive | awk -F/ '{print $NF}'`
      if [[ "$2" != "" ]]; then
        destDir=$familyDir/$dirInArch
        destDir=`eval "echo $destDir | $2"`
      fi
      if [[ "$3" != "" ]]; then
        destDir=$familyDir/$archiveName
        destDir=`eval "echo $destDir | $3"`
        destDir=`echo $destDir | sed 's/.tar.gz//g'`
      fi
      if [[ "$2" == "" && "$3" == "" ]]; then
        destDir=$familyDir/$dirInArch
      fi
      if [[ -d "$destDir" ]]; then
        echo -e "${CYAN}Dir $destDir exists - skipping${NC}"
      else
        tar xf $archive -C $familyDir
        if [[ "$2" != "" || "$3" != "" ]] && [[ ! -d $destDir ]]; then
          mv $familyDir/$dirInArch $destDir
        fi
        echo "$dirInArch extracted to $familyDir as $destDir"
      fi
    done
  fi
}




function copyFamilyAsFiles {
  files=`ls -f $cloudDir/$1/$1* 2>/dev/null`
  if [[ "$files" != "" ]]; then
    familyDir=$pfDir/$1
    makeDir $familyDir
    for file in $files; do
      fileName=$(echo $file | awk -F/ '{print $(NF)}')
      destFile=$familyDir/$fileName
      if [[ -f "$destFile" ]]; then
        echo -e "${CYAN}File $destFile exists - skipping${NC}"
      else
        cp $file $familyDir
        echo "$fileName copied to $familyDir"
      fi
    done
  fi
}

function copyFamilyAsDirs {
  dirs=`ls -d $cloudDir/$1/$1* 2>/dev/null`
  if [[ "$dirs" != "" ]]; then
    familyDir=$pfDir/$1
    makeDir $familyDir
    for dir in $dirs; do
      dirName=$(echo $dir | awk -F/ '{print $(NF)}')
      destDir=$familyDir/$dirName
      if [[ -d "$destDir" ]]; then
        echo -e "${CYAN}Directory $destDir exists - skipping${NC}"
      else
        cp -R $dir ${familyDir%/}
        echo -e "${GREEN}$destDir copied to $familyDir${NC}"
      fi
    done
  fi
}

function verifyVersion {
  familyDir=$pfDir/$1
  for spec in `ls -d $familyDir/* 2>/dev/null`; do
    expectedVersion1=`echo $spec | awk -F/ '{print $(NF)}' | awk -F- '{print $(NF)}'`
    expectedVersion2=`echo $spec | awk -F/ '{print $(NF)}' | awk -F- '{print $(NF-1)}'`
    actualVersion=$(eval $spec/$2)
    if [[ $actualVersion == "$expectedVersion1" || $actualVersion == "$expectedVersion2" ]]; then
      echo -e "${GREEN}$1 version is correct - $actualVersion${NC}"
    else
      echo -e "${RED}$1 version is not correct - expected: $expectedVersion1/$expectedVersion2, got: $actualVersion${NC}"
    fi
  done
}

# $1 - family
# $2 - expected
# $3 - actual
# $4 - description

function verify {
  familyDir=$pfDir/$1
  for spec in `ls -d $familyDir/* 2>/dev/null`; do
    expected=$(eval echo "$spec | awk -F/ '{print $NF}' | $2")
    actual=$(eval $spec/$3)
    if [[ $actual == "$expected" ]]; then
      echo -e "${GREEN}$1 $4 is correct for $spec - $actual${NC}"
    else
      echo -e "${RED}$1 $4 is not correct for $spec - expected: $expected, got: $actual${NC}"
    fi
  done
}

function createVariables2 {
  familyDirs=`ls -d $pfDir/$1/* 2>/dev/null`
  if [[ "$familyDirs" != "" ]]; then
    maxVersionToCompare=0
    maxVersion=""
    upperName=`echo $2 | awk '{print toupper($0)}'`
    echo "# $1" >> $varFile
    for specPath in $familyDirs; do
      spec=`basename $specPath`
      if [[ "$3" == "" ]]; then
        version=$(echo $spec | awk -F- '{print $NF}')
      else
        version=$(eval " echo $spec | $3")
      fi
      majorVersion=$(echo $version | cut -d. -f1)
      minorVersion=$(echo $version | cut -d. -f2)
      version=${majorVersion}_$minorVersion
      compactVersion=$majorVersion$minorVersion
      minorVersionNumber=`echo $minorVersion | sed s/[a-z]*//g`
      versionToCompare=$((10000 * $majorVersion + $minorVersionNumber))
      if [[ $versionToCompare -gt $maxVersionToCompare ]]; then
        maxVersionToCompare=$versionToCompare
        maxVersion=$version
        maxHomeVar="${upperName}${version}_HOME"
      fi
      specHomeVar="${upperName}${version}_HOME"
      homeVar="${upperName}_HOME"
      echo "export $specHomeVar=$specPath" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
      if [[ -d "$specPath/bin" ]]; then
        echo "alias use$2${compactVersion}='export $homeVar=\$$specHomeVar; export PATH=\$$homeVar/bin:\$PATH'" >> $aliasesFile
      else
        echo "alias use$2${compactVersion}='export $homeVar=\$$specHomeVar; export PATH=\$$homeVar:\$PATH'" >> $aliasesFile
      fi
    done;


    echo "export $homeVar=\$$maxHomeVar" >> $varFile
    if [[ -d "$specPath/bin" ]]; then
      echo "export PATH=\$$homeVar/bin:\$PATH" >> $varFile
    else
      echo "export PATH=\$$homeVar:\$PATH" >> $varFile
    fi
    . $varFile
  fi
}

# $1 - family
# $2 - name
# $3 - version extractor
# #4 - additional discriminator
function createVariables {
  specDirs=`ls -d $familyDir/* 2>/dev/null`
  if [[ "$specDirs" != "" ]]; then
    local maxVersion=0
    local familyDir=$pfDir/$1
    local upperName=`echo $2 | awk '{print toupper($0)}'`
    echo "# $1" >> $varFile
    for specPath in $specDirs; do
      local spec=`basename $specPath`
      local version=$(eval " echo $spec | $3")
      if [[ "$4" != "" ]]; then
        local disc=$(eval " echo $spec | $4")
        local discPartVar="_$disc"
      fi
      if [[ $version -gt $maxVersion ]]; then
        maxVersion=$version
        local maxHomeVar="${upperName}${version}${discPartVar}_HOME"
      fi
      local specHomeVar="${upperName}${version}${discPartVar}_HOME"
      local homeVar="${upperName}_HOME"
      echo "export $specHomeVar=$specPath" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
      if [[ -d "$specPath/bin" ]]; then
        echo "alias use$2${version}${disc}='export $homeVar=\$$specHomeVar; export PATH=\$$homeVar/bin:\$PATH'" >> $aliasesFile
      else
        echo "alias use$2${version}${disc}='export $homeVar=\$$specHomeVar; export PATH=\$$homeVar:\$PATH'" >> $aliasesFile
      fi
    done;

    echo "export $homeVar=\$$maxHomeVar" >> $varFile
    if [[ -d "$specPath/bin" ]]; then
      echo "export PATH=\$$homeVar/bin:\$PATH" >> $varFile
    else
      echo "export PATH=\$$homeVar:\$PATH" >> $varFile
    fi

    . $varFile
  fi
}

function backslashWhenWindows {
  if [[ "$system" == "win" ]]; then
    finalPath=$(echo "$1" | sed 's|/c|c:|g' | sed 's|/|\\|g')
  else
    finalPath="$1"
  fi
  echo "$finalPath"
}

function driveNotationWhenWindows {
  if [[ "$system" == "win" ]]; then
    finalPath=$(echo "$1" | sed 's|/c|c:|g')
  else
    finalPath="$1"
  fi
  echo "$finalPath"
}

# calculate system
osname=`uname`
if [[ "$USERPROFILE" != "" ]]; then
  system="win"
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

if [[ "$useStandardPfDir" == "y" ]]; then
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
. orchestrate-java-oracle-win.sh
. orchestrate-java-oracle-mac.sh
. orchestrate-java-oracle-linux.sh
. orchestrate-java-oracle.sh
. orchestrate-java-openjdk.sh
. orchestrate-java-jce-policy.sh
. orchestrate-java.sh
. orchestrate-rust.sh
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
. orchestrate-intellij-idea-linux.sh
. orchestrate-intellij-idea-settings.sh
. orchestrate-atom.sh
. orchestrate-password.sh
. orchestrate-backups-script.sh
. orchestrate-postgres.sh
. orchestrate-open-shift.sh
. orchestrate-functions.sh
. orchestrate-bashrc.sh
