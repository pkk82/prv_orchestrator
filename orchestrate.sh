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

# calculate system
osname=`uname`
if [ "$USERPROFILE" != "" ]; then
	system="windows"
	mainDir="/c"
elif [[ "$osname" == "Linux" ]]; then
	system="linux"
	mainDir=$HOME
fi
echo -e "${GREEN}Detected system: $system${NC}"

# calculate cloud dir
cloudDirDefault="$mainDir/vd/GoogleDrive/software"
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


varFile="$HOME/.bash_variables"
echo "export CLOUD_SOFTWARE_DIR=$cloudDirDefault" > $varFile
echo "export PF_DIR=$pfDir" >> $varFile

. orchestrate-aliases.sh
. orchestrate-java.sh
. orchestrate-java-jce-policy.sh
. orchestrate-maven.sh
. orchestrate-maven-settings.sh
. orchestrate-maven-toolchains.sh
. orchestrate-gradle.sh
. orchestrate-scala.sh
. orchestrate-kafka.sh
. orchestrate-nodejs.sh
. orchestrate-vscode.sh
. orchestrate-intellij-idea.sh
. orchestrate-bashrc.sh


