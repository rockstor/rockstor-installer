#!/bin/bash
# Bash parameters
set -e
set -u
#set -x

echo "================================================="
echo "update vagrant image with latest openSUSE updates"
echo "================================================="
sudo zypper refresh
sudo zypper up

echo "================================================="
echo "add Python 3.11 and git packages"
echo "================================================="
sudo zypper -n install python311 git

echo "================================================="
echo "install kiwi-ng 10.x and other dependencies"
echo "================================================="
sudo zypper -n addrepo https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6/ appliance-builder
sudo zypper --gpg-auto-import-keys refresh appliance-builder
# for TW kiwi-ng package = python3-kiwi for LEAP 15.6 = python311-kiwi
sudo zypper -n install python311-kiwi btrfsprogs gfxboot qemu-tools gptfdisk e2fsprogs squashfs xorriso dosfstools binutils xz

echo "================================================="
echo "verify kiwi-ng version. v10.2.13 or higher"
echo "================================================="
sudo kiwi-ng --version

echo "================================================="
echo "Done"
echo "================================================="