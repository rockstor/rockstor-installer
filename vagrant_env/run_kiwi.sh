#!/bin/bash
# Bash parameters
set -e
set -u
#set -x

echo "setting Profile Parameter"
# rockstor.kiwi profile to be used during iso generation
PROFILE="Leap15.6.x86_64"

echo "============================================="
echo "Initialization"
echo "============================================="
echo "setting profile parameters"
echo "============================================="

# if boxplugin were to be used
# Memory and CPUs need to be less than stipulated in the Vagrantfile
# MEM="6G"
# CPU="3"

# Vagrant Home Path
HOME_PATH="/home/vagrant"
# Default shared folder with Vagrant Host
REPO_SOURCE_PATH="/vagrant"
# cloned Repo Path inside Vagrant Box
REPO_PATH="/home/vagrant/repo"
# Github Repository to be cloned
REPO_URL="https://github.com/rockstor/rockstor-installer.git"
# Kiwi-ng executable Path
KIWI_NG_PATH="/usr/bin"
# Kiwi-ng final image storage location
KIWI_IMAGES="/home/vagrant/kiwi-images"

DESCRIPTION="./"

echo "============================================="
echo "clean up relevant directories"
echo "============================================="

if [ -a "$KIWI_IMAGES" ]; then
   echo "kiwi images directory exists and will be deleted"
   sudo rm -rf "$KIWI_IMAGES"
else
   echo "no cleanup required"
fi

if [ -a "$REPO_PATH" ]; then
   echo "repository directory exists and will be deleted"
   sudo rm -rf "$REPO_PATH"
else
   echo "no cleanup required"
fi


echo "================================================="
echo "Starting Build"
echo "================================================="
echo "Get git into Vagrant Box"
echo "================================================="

if [ ! -e ${REPO_PATH} ]; then
   echo "loading from github"
   sudo git clone ${REPO_URL} ${REPO_PATH}
fi

echo "================================================="
echo "insert updated rockstor.kiwi from local directory"
echo "================================================="
# force copy to have the latest version inside the vagrant box
if [ -a "$REPO_SOURCE_PATH"/rockstor.kiwi ]; then
   sudo cp -fv "$REPO_SOURCE_PATH"/rockstor.kiwi "$REPO_PATH"/rockstor.kiwi
else
   echo "using rockstor.kiwi file from github instead"
fi

echo "================================================="
echo "executing kiwi-ng"
echo "================================================="
# change into repo directory before executing kiwi-ng
cd "$REPO_PATH"
# sudo "$KIWI_NG_PATH"/kiwi-ng --profile="$PROFILE" --type oem system boxbuild --box-memory "$MEM" --box-smp-cpus="$CPU" --box leap -- --description "$DESCRIPTION" --target-dir "$KIWI_IMAGES"
sudo "$KIWI_NG_PATH"/kiwi-ng --profile="$PROFILE" --type oem system build --description "$DESCRIPTION" --target-dir "$KIWI_IMAGES"

echo "================================================="
echo "Copying image directory to local"
echo "================================================="
# wildcard expressions should be outside of the quotes to not be interpreted as string
sudo cp -f "$KIWI_IMAGES/"Rockstor* "$REPO_SOURCE_PATH/kiwi-images"
sudo cp -f "$KIWI_IMAGES/"kiwi*.* "$REPO_SOURCE_PATH/kiwi-images"
sudo cp -f "$KIWI_IMAGES/build/image-root.log" "$REPO_SOURCE_PATH/kiwi-images"

echo "================================================="
echo "Clean up kiwi-images and git repo"
echo "================================================="

sudo rm -rf "$KIWI_IMAGES"
sudo rm -rf "$REPO_PATH"

echo "================================================="
echo "Finished Build"
echo "================================================="
echo "Status and result logs can be found"
echo "in $REPO_SOURCE_PATH directory"
echo "Auf Wiedersehen"
echo "================================================="