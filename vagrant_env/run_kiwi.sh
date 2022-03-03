#!/bin/bash
# Bash parameters
set -e
set -u
#set -x

# Processing Profile Parameters
PROFILE="Leap15.3.x86_64"

# Memory and CPUs need to be less than stipulated in the Vagrantfile
MEM="6G"
CPU="3"

# Set Path Variables
HOME_PATH="/home/vagrant"
REPO_SOURCE_PATH="/home/vagrant/rockstor-installer"
REPO_PATH="/home/vagrant/repo"
REPO_URL="https://github.com/rockstor/rockstor-installer.git"
KIWI_NG_PATH="/home/vagrant/kiwi-env/bin"
KIWI_IMAGES="/home/vagrant/kiwi-images/"
DESCRIPTION="./"

echo '============================================='
echo 'Starting Build'
echo '============================================='
echo 'Get most recent git into Vagrant Box'
echo '============================================='

if [ ! -e ${REPO_PATH} ]; then
	sudo git clone ${REPO_URL} ${REPO_PATH}
fi

echo '============================================='
echo 'insert rockstor.kiwi from local directory'
echo '============================================='
# force copy to have the latest version inside the vagrant box
sudo cp -fv "$REPO_SOURCE_PATH"/rockstor.kiwi "$REPO_PATH"/rockstor.kiwi

echo '============================================='
echo 'executing kiwi-ng'
echo '============================================='
# change into repo directory before executing kiwi-ng
cd "$REPO_PATH"
sudo "$KIWI_NG_PATH"/kiwi-ng --profile="$PROFILE" --type oem system boxbuild --box-memory "$MEM" --box-smp-cpus="$CPU" --box leap -- --description "$DESCRIPTION" --target-dir "$KIWI_IMAGES"

echo '============================================='
echo 'Copying image directory to local'
echo '============================================='
# force copy to outside of vagrant box
sudo cp -fRv "$KIWI_IMAGES" "$REPO_SOURCE_PATH"

echo '============================================='
echo 'Clean up kiwi-images and git repo'
echo '============================================='
cd "$HOME_PATH"
sudo rm -rf "$KIWI_IMAGES"
sudo rm -rf "$REPO_PATH"
echo '============================================='
echo 'Finished Build'
echo '============================================='
echo 'Status and result logs can be found in "$REPO_SOURCE_PATH" directory'
echo 'Auf Wiedersehen'
echo '============================================='
