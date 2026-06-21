#!/bin/bash

# Optional configuration script while creating the unpacked image. This script
# is called at the end of the installation, but before the package scripts
# have run. It is designed to configure the image system, such as the
# activation or deactivation of certain services (insserv). The call is not
# made until after the switch to the image has been made with chroot.

# https://osinside.github.io/kiwi/concept_and_workflow/shell_scripts.html
# "... usually used to apply a permanent and final change of data in the root tree,
# such as modifying a package-specific config file."

#======================================
# Functions...
# https://osinside.github.io/kiwi/concept_and_workflow/shell_scripts.html#profile-environment-variables
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey

#==========================================
# Import Rockstor's rpm/repo GPG Public Key
# https://rockstor.com/ROCKSTOR-GPG-KEY
#------------------------------------------

rpm --erase gpg-pubkey-5f043187 || true
rpm --import https://rockstor.com/ROCKSTOR-GPG-KEY

#=========================================
# Auto import all compatible repo GPG keys
#-----------------------------------------
zypper --non-interactive --gpg-auto-import-keys refresh

#======================================
# Deactivate services
#--------------------------------------
baseRemoveService wicked
baseRemoveService apparmor

#======================================
# Activate services
#--------------------------------------
baseInsertService sshd
baseInsertService grub_config
baseInsertService dracut_hostonly
baseInsertService jeos-firstboot
baseInsertService NetworkManager

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 3

#==========================================
# remove package docs
#------------------------------------------
rm -rf /usr/share/doc/packages/*
rm -rf /usr/share/doc/manual/*

#======================================
# Disable installing documentation
#--------------------------------------
sed -i 's/.*rpm.install.excludedocs.*/rpm.install.excludedocs = yes/g' /etc/zypp/zypp.conf

#======================================
# Disable recommends
#--------------------------------------
sed -i 's/.*solver.onlyRequires.*/solver.onlyRequires = true/g' /etc/zypp/zypp.conf

#=====================================
# Configure snapper
#-------------------------------------
echo "Enabling snapper config ..."
baseUpdateSysConfig /etc/sysconfig/snapper SNAPPER_CONFIGS root

#=====================================
# Enable chrony if installed
#-------------------------------------
if [ -f /etc/chrony.conf ]; then
    suseInsertService chronyd
fi

#=====================================
# Edit the base distro openSUSE license files in accordance with the following:
# https://en.opensuse.org/Archive:Making_an_openSUSE_based_distribution
# Files to edit /usr/share/licenses/product/base/*.txt
#-------------------------------------
shopt -s nullglob
for license_file in /usr/share/licenses/product/base/*.txt
do
    sed -i 's/openSUSE®/Rockstor "Built on openSUSE"/g' "${license_file}"
    sed -i 's/The openSUSE Project/The Rockstor Project/g' "${license_file}"
    sed -i 's/openSUSE Leap /Rockstor "Built on openSUSE" Leap /g' "${license_file}"
    sed -i 's/OPENSUSE Leap /Rockstor "Built on openSUSE" Leap /g' "${license_file}"
    sed -i 's/openSUSE Tumbleweed /Rockstor "Built on openSUSE" Tumbleweed /g' "${license_file}"
    sed -i 's/OPENSUSE Tumbleweed /Rockstor "Built on openSUSE" Tumbleweed /g' "${license_file}"
    sed -i 's/OPENSUSE/ROCKSTOR/g' "${license_file}"

    sed -i 's/$50US/1ST STABLE UPDATES SUBSCRIPTION PAYED/g' "${license_file}"
    sed -i 's/$50/1ST STABLE UPDATES SUBSCRIPTION PAYED/g' "${license_file}"
    sed -i 's/50 USD/1ST STABLE UPDATES SUBSCRIPTION PAYED/g' "${license_file}"
    sed -i 's/(50 $)/(1ST STABLE UPDATES STABLE UPDATES SUBSCRIPTION PAYED)/g' "${license_file}"
    sed -i 's/(US \$ 50)/(1ST STABLE UPDATES SUBSCRIPTION PAYED)/g' "${license_file}"
    sed -i 's/50 $/1ST STABLE UPDATES SUBSCRIPTION PAYED/g' "${license_file}"
    sed -i 's/50/1ST STABLE UPDATES SUBSCRIPTION PAYED/g' "${license_file}"
    sed -i 's/US-DOLLAR//g' "${license_file}"
    sed -i 's/US\$//g' "${license_file}"

    sed -i 's/2008-..../2024/g' "${license_file}"
done
# Alter the distro display name to add the suggested "Rockstor built on ..." prefix.
sed -i 's/PRETTY_NAME="openSUSE/PRETTY_NAME="Rockstor built on openSUSE/g' /usr/lib/os-release
# Alter BUG_REPORT_URL
sed -i 's/https:\/\/bugs.opensuse.org/https:\/\/forum.rockstor.com/g' /usr/lib/os-release
# Alter HOME_URL
sed -i 's/https:\/\/www.opensuse.org/https:\/\/rockstor.com/g' /usr/lib/os-release
# Alter DOCUMENTATION_URL
sed -i 's/^DOCUMENTATION_URL.*/DOCUMENTATION_URL="https:\/\/rockstor.com\/docs"/' /usr/lib/os-release

#======================================
# Apply grub configs
# Setup Grub Distributor option
#--------------------------------------
echo >> /etc/default/grub
echo "# Set distributor for custom menu text" >> /etc/default/grub
echo 'GRUB_DISTRIBUTOR="Rockstor NAS"' >> /etc/default/grub
echo >> /etc/default/grub

exit 0