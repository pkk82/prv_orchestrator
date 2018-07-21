#!/usr/bin/env bash
NC='\033[0m'; YELLOW='\033[0;33m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'

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

# calculate system
osname=`uname`
if [ "$USERPROFILE" != "" ]; then
  system="windows"
elif [[ "$osname" == "Linux" ]]; then
  system="linux"
elif [[ "$osname" == "Darwin" ]]; then
  system="mac"
fi
positiveMessage "Detected system: $system"

# detect dropbox directory
cloudDir=`askWithDefault "Enter path to dropbox" "$HOME/vd/Dropbox"`

# validate sudo
if [ "$system" != "windows" ]; then
  actionMessage "Check if `whoami` belongs to sudo"
  validateSudo=`sudo -v 2>&1`

  if [ "$validateSudo" == "" ]; then
    positiveMessage "User `whoami` is in sudo"
  else
    warningMessage "User `whoami` is not in sudo"
    actionMessage "Execute: "
    echo -e "  su -"
    echo -e "  usermod -a -G sudo `whoami`"
    echo -e "  shutdown -r"
    exit
  fi
fi

# grab user details
userDefault=`whoami`
user=`askWithDefault "Enter username" "$userDefault"`

# grab host
hostDefault=`hostname | sed "s/\.local$//g"`
host=`askWithDefault "Enter hostname" "$hostDefault"`


# validate git
validateGit=`git --version 2>&1`
if [[ "$validateGit" == *"git version"* ]]; then
  positiveMessage "git found"
else
  warningMessage "git not found"
  sudo apt-get install git
fi

# set git username
gitUserDefault=`git config --list | grep user.name | cut -d= -f2`
if [ "$gitUserDefault" == "" ]; then
  gitUserDefault="$user@$host"
fi
gitUser=`askWithDefault "Enter git user name" "$gitUserDefault"`
git config --global user.name "$gitUser"

# set git user email
gitEmailDefault=`git config --list | grep user.email | cut -d= -f2`
gitEmail=`askWithDefault "Enter git user email" "$gitEmailDefault"`
git config --global user.email "$gitEmail"

# set auto rebase for git
git config --global pull.rebase true

# ssh key
if [ -f "$HOME/.ssh/id_rsa" ]; then
  positiveMessage "private key found"
else
  actionMessage "Generating ssh private key"
  ssh-keygen -C $gitUser -f $HOME/.ssh/id_rsa -N ""
fi

# gpg
gpgKeys=`gpg --list-keys`
if [ "$gpgKeys" == "" ]; then
  export GNUPGHOME="$HOME/.gnupg"
  gpgPassword=`askPassword "Enter gpg password"`
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
  positiveMessage "Found gpg keys: $gpgKeys"
fi

# curl
curlTest=`curl 2>&1`
if [[ -f "/usr/bin/curl" || "$curlTest" == "curl:"* ]]; then
  positiveMessage "curl found"
else
  warningMessage "curl not found"
  sudo apt-get install curl
fi


# public keys
publicKey=`cat "$HOME/.ssh/id_rsa.pub" | tr -d '\n' | awk '{print $1 " " $2}'`
label="$user@$host"

# bitbucket
actionMessage "Checking bitbucket ssh key"
bitbucketUser="pkk82"
bitbucketPassword=`askPassword "Enter bitbucket password for user '$bitbucketUser'"`
bitbucketSshUrl="https://api.bitbucket.org/2.0/users/$bitbucketUser/ssh-keys"
serverKeys=`curl -u "$bitbucketUser:$bitbucketPassword" "$bitbucketSshUrl" | python -c $'import json, sys\nfor e in json.load(sys.stdin)["values"]: print(str(e["uuid"]) + " " + e["label"] + " " + e["key"])'`
labelAndKeyExists=`echo "$serverKeys" | grep "$label" | grep "$publicKey"`
labelExists=`echo "$serverKeys" | grep "$label"`
keyExists=`echo "$serverKeys" | grep "$publicKey"`

if [ "$labelAndKeyExists" != "" ]; then
  positiveMessage "Public key found"
else
  warningMessage "Public key not found"

  if [ "$keyExists" != "" ]; then
    oldLabel=`echo "$serverKeys" | grep "$publicKey" | awk '{print $2}'`
    id=`echo "$serverKeys" | grep "$publicKey" | awk '{print $1}'`
    actionMessage "Removing public key with label $oldLabel"
    curl -X DELETE -u "$bitbucketUser:$bitbucketPassword" "$bitbucketSshUrl/$id"
  fi

  if [ "$labelExists" != "" ]; then
    id=`echo "$serverKeys" | grep "$label" | awk '{print $1}'`
    actionMessage "Removing public key with label $label"
    curl -X DELETE -u "$bitbucketUser:$bitbucketPassword" "$bitbucketSshUrl/$id"
  fi

  actionMessage "Adding public key"
  curl -X POST -u "$bitbucketUser:$bitbucketPassword" -H "Content-Type: application/json" -d "{\"key\": \"$publicKey\", \"label\": \"$label\"}" $bitbucketSshUrl
fi

# github
actionMessage "Checking github ssh key"
gitHubUser="pkk82"
gitHubPassword=`askPassword "Enter github password for user '$gitHubUser'"`
gitHubSshUrl="https://api.github.com/user/keys"
serverKeys=`curl -u "$gitHubUser:$gitHubPassword" "$gitHubSshUrl" | python -c $'import json, sys\nfor e in json.load(sys.stdin): print(str(e["id"]) + " " + e["title"] + " " + e["key"])'`
labelAndKeyExists=`echo "$serverKeys" | grep "$label" | grep "$publicKey"`
labelExists=`echo "$serverKeys" | grep "$label"`
keyExists=`echo "$serverKeys" | grep "$publicKey"`

if [ "$labelAndKeyExists" != "" ]; then
  positiveMessage "Public key found"
else
  warningMessage "Public key not found"

  if [ "$keyExists" != "" ]; then
    oldLabel=`echo "$serverKeys" | grep "$publicKey" | awk '{print $2}'`
    id=`echo "$serverKeys" | grep "$publicKey" | awk '{print $1}'`
    actionMessage "Removing public key with label $oldLabel"
    curl -X DELETE -u "$gitHubUser:$gitHubPassword" "$gitHubSshUrl/$id"
  fi

  if [ "$labelExists" != "" ]; then
    id=`echo "$serverKeys" | grep "$label" | awk '{print $1}'`
    actionMessage "Removing public key with label $label"
    curl -X DELETE -u "$gitHubUser:$gitHubPassword" "$gitHubSshUrl/$id"
  fi

  actionMessage "Adding public key"
  curl -X POST -u "$gitHubUser:$gitHubPassword" -H "Content-Type: application/json" -d "{\"key\": \"$publicKey\", \"title\": \"$label\"}" $gitHubSshUrl
fi

# download this project to workspace
workspaceDir=`askWithDefault "Enter path to workspace" "$HOME/workspace"`
mkdir -p "$workspaceDir/prv"
repoDir="$workspaceDir/prv/orchestrator"
if [ ! -d "$repoDir" ]; then
  warningMessage "Orchestrator project not found, cloning it to $repoDir"
  git clone "git@bitbucket.org:$bitbucketUser/prv_orchestrator.git" "$repoDir"
else
  positiveMessage "Orchestrator project found"
fi

# copy file to dropbox
me=`basename "$0"`
dest="$cloudDir/scripts/$me"
if [ "`pwd`/$me" != "$dest" ]; then
	cp -f $me $dest
fi
