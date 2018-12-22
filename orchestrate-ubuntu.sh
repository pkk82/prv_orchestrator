#!/usr/bin/env bash

# update apt-get
sudo apt-get update && sudo apt-get dist-upgrade && sudo apt-get autoremove

# install 32bit architecture
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386

# install language packages
sudo apt-get install hunspell-en-gb
sudo apt-get install hunspell-pl

# set keys
gsettings set org.gnome.desktop.wm.keybindings begin-move  "[]"
gsettings set org.gnome.desktop.wm.keybindings begin-resize  "[]"

gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up  "['<Shift><Alt>o']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-down  "['<Shift><Alt>l']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left  "['<Shift><Alt>m']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right  "['<Shift><Alt>greater']"

gsettings set org.gnome.desktop.wm.keybindings move-to-side-n  "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-s  "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-w  "[]"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-e  "[]"

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Primary><Alt><Super>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Primary><Alt><Super>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Primary><Alt><Super>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Primary><Alt><Super>4']"

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Primary><Alt><Super>o']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Primary><Alt><Super>l']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Primary><Alt><Super>m']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Primary><Alt><Super>period']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-last "['<Primary><Alt><Super>slash']"

gsettings set org.gnome.desktop.wm.keybindings move-to-corner-nw "['<Shift><Ctrl><Super>braceleft']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-ne "['<Shift><Ctrl><Super>braceright']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-sw "['<Shift><Ctrl><Super>quotedbl']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-se "['<Shift><Ctrl><Super>|']"

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Alt><Super>o']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Alt><Super>l']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Alt><Super>m']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Alt><Super>period']"

gsettings set org.cinnamon.desktop.keybindings.media-keys terminal "['<Primary><Shift>t']"
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal '<Primary><Shift>t'

# install ansible
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible

# install virtual box
sudo apt-get -y install gcc make linux-headers-$(uname -r) dkms
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >> /etc/apt/sources.list'
sudo apt-get update
sudo apt-get install virtualbox-5.2

# install gnu-smalltalk
sudo apt install gnu-smalltalk

# install docker
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get update
sudo apt-get install docker-ce

# allow user to run docker
sudo groupadd docker
sudo usermod -aG docker pkk82
sudo chown "pkk82":"pkk82" /home/pkk82/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R

# run docker on startup
sudo systemctl enable docker

# install kubernetes
sudo snap install kubectl --classic

# install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube

# install xclip
sudo apt install xclip

# install heroku
sudo snap install --classic heroku
