#!/bin/bash

# Optional configuration script while creating the unpacked image. This script
# is called at the end of the installation, but before the package scripts
# have run. It is designed to configure the image system, such as the
# activation or deactivation of certain services (insserv). The call is not
# made until after the switch to the image has been made with chroot.

# https://osinside.github.io/kiwi/concept_and_workflow/shell_scripts.html
# "... usually used to apply a permanent and final change of data in the root tree,
# such as modifying a package-specific config file."

# Functions...
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

#======================================
# Import Rockstor GPG Key
# https://raw.githubusercontent.com/rockstor/rockstor-core/master/conf/ROCKSTOR-GPG-KEY
# N.B. Expires 2025-05-29
#--------------------------------------
t=$(mktemp)
cat - <<EOF > $t
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQENBF7SoJkBCADTKeUnVek8p8bXlDF3vhABCCq9FFYf6NN5ZrtDoZUa2Zysazij
lqusMdpdswuqxsre7fjsGtMS9sGf16Yp0PUpqCel/fH/vN/foV38ur939gXswa3E
+ZbVtltSnzSJZxqVGpgK8Lih3jFoyC8abhEfnCLXKBTEdpZPOgyDtanM1h9EHsZG
wjzw2vi/CgCiPJwdIeNrrBp3IO69t4PfgHWCAfeHAuVscOecfJ4u0PZWLchE8tsH
UUj5ijXoA1yPMSR8v5lLJfB5ElIYHP+Uqs4RhX2cVFVJN2IlaR+O9b2EAWjylwk4
b9SxJe3aTGkMESc3XVSrtyMAntNivIjqDt6nABEBAAG0QlRoZSBSb2Nrc3RvciBQ
cm9qZWN0IChSb2Nrc3RvciBEZXZlbG9wbWVudCkgPHN1cHBvcnRAcm9ja3N0b3Iu
Y29tPokBVAQTAQgAPhYhBBXrUqcB5WwRYHPuURxCYvJfBDGHBQJe0qCZAhsDBQkJ
ZgGABQsJCAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEBxCYvJfBDGH/OMH/2l5yd3W
SONhuXVwFjpY70iE8IM+Y6PPGUz5pFTCKJ8EpSznnuqFzlCr7Pgi9OFLoWoX6CAt
h6dH/E+22ktZ0Mgi7Z8zkyyc5265iyk2liW49GLpeC2PIjkEzKv/7oNOpLg6sXH8
i9Z9q+3RXPGUOw8I5uR1kYDwDtMNBxnWaTsL5qHRSDxR0WgOFgilMQVeE1uoxd3m
SeLW4cnzw/2MGYKsniHCePB70WSEYZaX8kLOXVsskBn0/LnVICB2cSo7cKz4YmUe
MTqgCQwMURIn8eSz/8gxl4rONal4CGZTb899VLIqgqr5IEEqas3o8WJbRf/I6akJ
I9yXyz+yWhBlTTU=
=8Urm
-----END PGP PUBLIC KEY BLOCK-----
EOF
rpm --import $t
rm -f $t

#======================================
# Auto import all repo GPG keys
#--------------------------------------
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
# Files to edit /usr/share/licenses/openSUSE-release/*.txt
#-------------------------------------
shopt -s nullglob
for license_file in /usr/share/licenses/openSUSE-release/*.txt
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
#======================================
# Default kernel boot options
#--------------------------------------
# Common to all profiles
cmdline=('plymouth.enable=0' 'rd.kiwi.oem.maxdisk=5000G')
# Machine targets
case "${kiwi_profiles}" in
  *x86_64) cmdline+=('nomodeset') ;;
	*RaspberryPi4) cmdline+=('console=ttyS0,115200' 'console=tty') ;;
	*ARM64EFI) cmdline+=('earlycon') ;;
esac
# SELinux config - if installed
if [[ -e /etc/selinux/config ]]; then
  # `enforcing=0` for permissive (default), 1 for enforcing
	cmdline+=('security=selinux' 'selinux=1')
	sed -i -e 's|^SELINUX=.*|SELINUX=permissive|g' \
	       -e 's|^SELINUXTYPE=.*|SELINUXTYPE=targeted|g' \
	       "/etc/selinux/config"
fi
if [ -e /etc/default/grub ]; then
	sed -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.*\$#GRUB_CMDLINE_LINUX_DEFAULT=\"${cmdline[*]}\"#" /etc/default/grub
fi

#======================================
# Setup Grub Distributor option
#--------------------------------------
echo >> /etc/default/grub
echo "# Set distributor for custom menu text" >> /etc/default/grub
echo 'GRUB_DISTRIBUTOR="Rockstor NAS"' >> /etc/default/grub
echo >> /etc/default/grub

exit 0