# install 32bit architecture
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386

# install languate packates
sudo apt-get install hunspell-en-gb
sudo apt-get install hunspell-pl
