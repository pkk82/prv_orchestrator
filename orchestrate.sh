#!/usr/bin/env bash
NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'

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
	for zip in `ls -d $cloudDir/$1/*.zip`; do
		zipDir=$(unzip -l $zip | awk '{print $4}' | grep '/' | sed -e 's|/.*||' | uniq)
		zipDir=${zipDir%/}
		destFolder=$familyDir/$zipDir
		if [ -d "$destFolder" ]; then
			echo -e "${CYAN}Dir $destFolder exists - skipping${NC}"
		else
			unzip -q $zip -d $familyDir
			echo "$zipDir extracted to $familyDir"
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

function createVariables1 {
	maxVersionToCompare=0
	maxVersion=""
	familyDir=$pfDir/$1
	echo "# $1" >> $varFile
	for spec in `ls -d $familyDir/* 2>/dev/null`; do
		version=$(eval " echo $spec | $3")
		if [[ $version -gt $maxVersion ]]; then
			maxVersion=$version
		fi
		echo "export $2${version}_HOME=$spec" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
		if [ -d "$spec/bin" ]; then
			echo "alias use-$1-${version}='export $2_HOME=\$$2${version}_HOME; export PATH=\$$2_HOME/bin:\$PATH'" >> $aliasesFile
		else
			echo "alias use-$1-${version}='export $2_HOME=\$$2${version}_HOME; export PATH=\$$2_HOME:\$PATH'" >> $aliasesFile
		fi
	done;

	if [[ "$maxVersion" != "" ]]; then
		echo "export $2_HOME=\$$2${maxVersion}_HOME" >> $varFile
		if [ -d "$spec/bin" ]; then
			echo "export PATH=\$$2_HOME/bin:\$PATH" >> $varFile
		else
			echo "export PATH=\$$2_HOME:\$PATH" >> $varFile
		fi
	fi
}

function createVariables2 {
	maxVersionToCompare=0
	maxVersion=""
	familyDir=$pfDir/$1
	echo "# $1" >> $varFile
	for spec in `ls -d $familyDir/* 2>/dev/null`; do
		version=$(echo $spec | awk -F- '{print $NF}')
		majorVersion=$(echo $version | cut -d. -f1)
		minorVersion=$(echo $version | cut -d. -f2)
		version=${majorVersion}_${minorVersion}
		versionToCompare=$((10000 * $majorVersion + $minorVersion))
		if [[ $versionToCompare -gt $maxVersionToCompare ]]; then
			maxVersionToCompare=$versionToCompare
			maxVersion=$version
		fi
		echo "export $2${version}_HOME=$spec" | sed "s|$pfDir|\$PF_DIR|" >> $varFile
		if [ -d "$spec/bin" ]; then
			echo "alias use-$1-${version}='export $2_HOME=\$$2${version}_HOME; export PATH=\$$2_HOME/bin:\$PATH'" >> $aliasesFile
		else
			echo "alias use-$1-${version}='export $2_HOME=\$$2${version}_HOME; export PATH=\$$2_HOME:\$PATH'" >> $aliasesFile
		fi
	done;

	if [[ "$maxVersion" != "" ]]; then
		echo "export $2_HOME=\$$2${maxVersion}_HOME" >> $varFile
		if [ -d "$spec/bin" ]; then
			echo "export PATH=\$$2_HOME/bin:\$PATH" >> $varFile
		else
			echo "export PATH=\$$2_HOME:\$PATH" >> $varFile
		fi
	fi
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
cloudDirDefault="$mainDir/vd/Dropbox/software"
echo -e -n "${CYAN}Enter path to software directory${NC} ($cloudDirDefault): "
read cloudDir
cloudDir=${cloudDir:-$cloudDirDefault}

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
echo "export CLOUD_SOFTWARE_DIR=$cloudDirDefault" > $varFile
echo "export PF_DIR=$pfDir" >> $varFile

. orchestrate-aliases.sh
. orchestrate-java.sh
. orchestrate-java-jce-policy.sh
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
. orchestrate-password.sh
. orchestrate-backups-script.sh
. orchestrate-postgres.sh
. orchestrate-bashrc.sh


