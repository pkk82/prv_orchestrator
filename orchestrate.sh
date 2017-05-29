NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'

function makeDir {
	if [ -d $1 ]; then
	    echo -e "${CYAN}Dir $1 already exists${NC}"
	elif mkdir $1; then
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
existingDirs=$(ls -d $mainDir/pf*)
echo "Existing pf directories:"
echo "$existingDirs"
pfDirDefault="$mainDir/pf-$(date '+%Y%m%d-%H%M')"
echo -e -n "${CYAN}Enter path to program files directory${NC} ($pfDirDefault): "
read pfDir
pfDir=${pfDir:-$pfDirDefault}
makeDir $pfDir

. orchestrate-java.sh


