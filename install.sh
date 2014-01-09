#!/bin/bash
#
# Requires and assumes sudo is installed
# 

#Install Apps
sudo apt-get install -y vim xfce4-terminal irssi awesome awesome-extra xorg slim git meld chromium 

#Setup VIM
ln -s ~/bash_scripts/templatevimrc ~/.vimrc

#Configure GIT
~/bash_scripts/gitconfig

#Setup XFCE4 Terminal
mkdir -p ~/.config/Terminal
ln -s ~/bash_scripts/terminalrc ~/.config/Terminal/terminalrc

#Setup AwsomeWM
mkdir -p ~/.config/awesome
ln -s ~/bash_scripts/rc.lua ~/.config/awesome/rc.lua
pushd ~/.config/awesome
git clone https://github.com/Tehsmash/awesome-themes.git themes
popd 
