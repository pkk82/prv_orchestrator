#!/usr/bin/env bash
NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'


# calculate system
osname=`uname`
if [ "$USERPROFILE" != "" ]; then
	system="windows"
	mainDir="/c"
elif [[ "$osname" == "Linux" ]]; then
	system="linux"
	mainDir=$HOME
elif [[ "$osname" == "Darwin" ]]; then
	system="mac"
	mainDir=$HOME
fi
echo -e "${GREEN}Detected system: $system${NC}"

# detect dropbox directory
cloudDirDefault="$mainDir/vd/Dropbox/scripts"
echo -e -n "${CYAN}Enter path to dropbox${NC} ($cloudDirDefault): "
read cloudDir
cloudDir=${cloudDir:-$cloudDirDefault}

# validate sudo
validateSudo=`sudo -v 2>&1`

if [ "$validateSudo" == "" ]; then
	echo -e "${GREEN}User `whoami` is in sudo${NC}"
else
	echo -e "${RED}User `whoami` is not in sudo${NC}"
	echo -e "${CYAN}Execute: ${NC}"
	echo -e "  su -"
	echo -e "  usermod -a -G sudo `whoami`"
	echo -e "  shutdown -r"
	exit
fi

# validate git
validateGit=`git --version 2>&1`
if [[ "$validateGit" == *"git version"* ]]; then
	echo -e "${GREEN}git found${NC}"
else
	echo -e "${RED}git not found${NC}"
	sudo apt-get install git
fi

# set git username
gitUserDefault=`git config --list | grep user.name | cut -d= -f2`
echo -e -n "${CYAN}Enter git user name${NC} ($gitUserDefault): "
read gitUser
gitUser=${gitUser:-$gitUserDefault}
git config --global user.name $gitUser

# set git user email
gitEmailDefault=`git config --list | grep user.email | cut -d= -f2`
echo -e -n "${CYAN}Enter git user email${NC} ($gitEmailDefault): "
read gitEmail
gitEmail=${gitEmail:-$gitEmailDefault}
git config --global user.email $gitEmail

# set auto rebase for git
git config --global pull.rebase true

# ssh key
if [ -f "$HOME/.ssh/id_rsa" ]; then
	echo -e "${GREEN}private key found${NC}"
else
	echo -e "${CYAN}private key not exist - generating one${NC}"
	ssh-keygen -C $gitUser -f $HOME/.ssh/id_rsa -N ""
fi

# curl
if [ -f "/usr/bin/curl" ]; then
	echo -e "${GREEN}curl found${NC}"
else
	echo -e "${RED}curl not found${NC}"
	sudo apt-get install curl
fi

# copy file to dropbox
me=`basename "$0"`
dest="$cloudDir/$me"
if [ "`pwd`/$me" != "$dest" ]; then
	cp -f $me $cloudDir/$me
fi
