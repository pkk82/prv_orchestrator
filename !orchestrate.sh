#!/usr/bin/env bash
NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'


# calculate system
osname=`uname`
if [ "$USERPROFILE" != "" ]; then
	system="windows"
elif [[ "$osname" == "Linux" ]]; then
	system="linux"
elif [[ "$osname" == "Darwin" ]]; then
	system="mac"
fi
echo -e "${GREEN}Detected system: $system${NC}"

# detect dropbox directory
cloudDirDefault="$HOME/vd/Dropbox"
echo -e -n "${CYAN}Enter path to dropbox${NC} ($cloudDirDefault): "
read cloudDir
cloudDir=${cloudDir:-$cloudDirDefault}

# validate sudo
if [ "$system" != "windows" ]; then
  echo -e "${CYAN}Check if `whoami` belongs to sudo${NC}"
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
fi


# grab user details
userDefault=`whoami`
echo -e -n "${CYAN}Enter username${NC} ($userDefault): "
read user
user=${user:-$userDefault}

# grab host
hostDefault=`hostname | sed "s/\.local$//g"`
echo -e -n "${CYAN}Enter hostname${NC} ($hostDefault): "
read host
host=${host:-$hostDefault}


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
if [ "$gitUserDefault" == "" ]; then
	gitUserDefault="$user@$host"
fi

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

# gpg
gpgKeys=`gpg --list-keys`
if [ "$gpgKeys" == "" ]; then
  export GNUPGHOME="$HOME/.gnupg"
  read -s -p "$(echo -e "${CYAN}Enter gpg password$NC: ")" gpgPassword
  printf "\n"
  rm /tmp/key
  cat > /tmp/key << EOF
%echo Generating a default key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $gitUser
Name-Email: $gitEmail
Expire-Date: 0
Passphrase: $gpgPassword
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
  gpg --batch --gen-key /tmp/key
  rm /tmp/key
else
  echo -e "${GREEN}Found gpg keys: $gpgKeys${NC}"
fi

# curl
curlTest=`curl 2>&1`
if [[ -f "/usr/bin/curl" || "$curlTest" == "curl:"* ]]; then
	echo -e "${GREEN}curl found${NC}"
else
	echo -e "${RED}curl not found${NC}"
	sudo apt-get install curl
fi


# public keys
publicKey=`cat "$HOME/.ssh/id_rsa.pub" | tr -d '\n' | awk '{print $1 " " $2}'`
label="$user@$host"

# bitbucket
echo -e "${CYAN}Check bitbucket ssh key${NC}"
bitbucketUser="pkk82"
bitbucketSshUrl="https://api.bitbucket.org/2.0/users/$bitbucketUser/ssh-keys"
serverKeys=`curl -X GET -u "$bitbucketUser" "$bitbucketSshUrl" | python -c $'import json, sys\nfor e in json.load(sys.stdin)["values"]: print(str(e["uuid"]) + " " + e["label"] + " " + e["key"])'`
labelAndKeyExists=`echo "$serverKeys" | grep "$label" | grep "$publicKey"`
labelExists=`echo "$serverKeys" | grep "$label"`
keyExists=`echo "$serverKeys" | grep "$publicKey"`

echo $labelExists
echo $keyExists
echo $labelAndKeyExists

if [ "$labelAndKeyExists" != "" ]; then
  echo -e "${GREEN}Public key found${NC}"
else
  echo -e "${RED}Public key not found${NC}"

  if [ "$keyExists" != "" ]; then
    oldLabel=`echo "$serverKeys" | grep "$publicKey" | awk '{print $2}'`
    id=`echo "$serverKeys" | grep "$publicKey" | awk '{print $1}'`
    echo -e "${CYAN}Removing public key with label $oldLabel${NC}"
    curl -X DELETE -u "$bitbucketUser" "$bitbucketSshUrl/$id"
  fi

  if [ "$labelExists" != "" ]; then
    id=`echo "$serverKeys" | grep "$label" | awk '{print $1}'`
    echo -e "${CYAN}Removing public key with label $label${NC}"
    curl -X DELETE -u "$bitbucketUser" "$bitbucketSshUrl/$id"
  fi

  echo -e "${CYAN}Adding public key${NC}"
  curl -X POST -u "$bitbucketUser" -H "Content-Type: application/json" -d "{\"key\": \"$publicKey\", \"label\": \"$label\"}" $bitbucketSshUrl
fi

# github
echo -e "${CYAN}Check github ssh key${NC}"
gitHubUser="pkk82"
gitHubSshUrl="https://api.github.com/user/keys"
serverKeys=`curl -X GET -u $gitHubUser "$gitHubSshUrl" | python -c $'import json, sys\nfor e in json.load(sys.stdin): print(str(e["id"]) + " " + e["title"] + " " + e["key"])'`
labelAndKeyExists=`echo "$serverKeys" | grep "$label" | grep "$publicKey"`
labelExists=`echo "$serverKeys" | grep "$label"`
keyExists=`echo "$serverKeys" | grep "$publicKey"`

if [ "$labelAndKeyExists" != "" ]; then
  echo -e "${GREEN}Public key found${NC}"
else
  echo -e "${RED}Public key not found${NC}"

  if [ "$keyExists" != "" ]; then
    oldLabel=`echo "$serverKeys" | grep "$publicKey" | awk '{print $2}'`
    id=`echo "$serverKeys" | grep "$publicKey" | awk '{print $1}'`
    echo -e "${CYAN}Removing public key with label $oldLabel${NC}"
    curl -X DELETE -u "$gitHubUser" "$gitHubSshUrl/$id"
  fi

  if [ "$labelExists" != "" ]; then
    id=`echo "$serverKeys" | grep "$label" | awk '{print $1}'`
    echo -e "${CYAN}Removing public key with label $label${NC}"
    curl -X DELETE -u "$gitHubUser" "$gitHubSshUrl/$id"
  fi

  echo -e "${CYAN}Adding public key${NC}"
  curl -X POST -u "$gitHubUser" -H "Content-Type: application/json" -d "{\"key\": \"$publicKey\", \"title\": \"$label\"}" $gitHubSshUrl
fi

# copy file to dropbox
me=`basename "$0"`
dest="$cloudDir/scripts/$me"
if [ "`pwd`/$me" != "$dest" ]; then
	cp -f $me $dest
fi
