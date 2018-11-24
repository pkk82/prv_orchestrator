#!/usr/bin/env bash

# update apt-get
sudo apt-get update

# install 32bit architecture
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386

# install languate packates
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

# install ansible
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible
