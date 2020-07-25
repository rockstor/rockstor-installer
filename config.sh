#!/bin/bash

# Optional configuration script while creating the unpacked image. This script
# is called at the end of the installation, but before the package scripts
# have run. It is designed to configure the image system, such as the
# activation or deactivation of certain services (insserv). The call is not
# made until after the switch to the image has been made with chroot.

# https://osinside.github.io/kiwi/working_with_kiwi/shell_scripts.html

# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Mount system filesystems
#--------------------------------------
baseMount

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
# Import repo GPG Key for
# obs://build.opensuse.org/network
# N.B. Expires 2020-03-30
#--------------------------------------
t=$(mktemp)
cat - <<EOF > $t
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.5 (GNU/Linux)

mQENBFJBt/wBCADAht3d/ilNuyzaXYw/QwTRvmjyoDvfXw+H/3Fvk1zlDZoiKPPc
a1wCVBINUZl7vYM2OXqbJwYa++JP2Q48xKSvC6thbRc/YLievkbcvTemf7IaREfl
CTjoYpoqXHa9kHMw1aALDm8CNU88jZmnV7v9L6hKkbYDxie+jpoj7D6B9JlxgNJ4
5dQyRNsFGVcIl4Vplt1HyGc5Q5nQI/VgS2rlF/IOXmhRQBc4LEDdU8R2IKnkU4ee
S7TWanAigGAQhxGuCkS39/CWzc1DhLhjlNhBl/+RTPejkqJtAy00ZLps3+RqUN1Y
CU/Fsr7aRlYVGqQ/BlptwV0XQ2VVYJX2oEBBABEBAAG0MG5ldHdvcmsgT0JTIFBy
b2plY3QgPG5ldHdvcmtAYnVpbGQub3BlbnN1c2Uub3JnPokBPAQTAQIAJgUCWmMc
aQIbAwUJDEAUbQYLCQgHAwIEFQIIAwQWAgMBAh4BAheAAAoJEGLrGgkXKA3fjsoI
ALSXmXzFCpTxg8a6tvXkqddY/qAmeBMNUf7hslI9wN3leNmCrnuHS8TbHWYJZgtw
8M5fKL3aRQYaIiqqm1XOUF0OqwYNDj5V3y38mM68NYOkzgSP7foMwZp9Y0TlGhtI
L8weA+2RUjB4hwwGMAYMqkRZyKW3NhPqdlGGoXac1ilwEyGXFHdOLbkhtyS+P2yb
/EvaKIN5cMLzRZKeYgdp9WuAirV+yV/SDbgvabW098lrWhGLltlRRDQgMV883p8I
ERMI1wlLFZGnHL3mfBWGeQ24M/DaBOdXQDtfBLCJ9nGztmDBUb8i6GFWU7nD2TGi
8mYUsED1ZDwO/0jdvJ4gSluIRgQTEQIABgUCUkG3/AAKCRA7MBG3a51lIzhdAJ9v
d6XPffMZRcCGgDEY5OaTn/MsCQCgrXbeZpFJgnirSrc8rRonvzYFiF4=
=Gvly
-----END PGP PUBLIC KEY BLOCK-----
EOF
rpm --import $t
rm -f $t

#======================================
# Import repo GPG Key for
# https://build.opensuse.org/project/show/shells
# N.B. Expires Unknown
#--------------------------------------
t=$(mktemp)
cat - <<EOF > $t
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.5 (GNU/Linux)

mQGiBEeWW10RBADvumfiqUVFRTo4UAGZcjsJ4mMNiMT84Oe34iDodBdy8lk7cdpe
DFRV0zLv9PFph0CyRysEh9fNKXyxW76x+o3zQLikoUXOycSqVszrsKfYOvedFAro
bbGZoWL7CZCrSmKAscxJESr9F8bem0KvDn07tn4N6+B8EDrapoNjw0RhJwCgmd5S
LRdbYbwvBboDY2AEg6zidp8D+gMY99cB92C9+93mx1+69aHf2wGwHIY9je7w9dgc
XIRqSoDZ7KufC+NuKMVh4ny6TqrgUikPrgt6Ccp2hYh7BlHjNScVPm6+e4HYtdTA
4uA8sPd6CTOMFqvJEvnNTsFqzdRhcQkecyODIgXO6eDT/eSyw6ZAsdBBxvoXq062
Lu5hBADJmqHo8CeqyfAd/sjTBrH4aNEn2j4NzSUg/14OjGSvLGaJk4H2elBuJ/0o
mfoMamRXwTNOysIbrcVBFc+B3rfRxbmQCtUvcDquCfOOGG5yW8Jz9eTMW+wbI1I3
wjdq2Bny4jeY+EkHEJvoaJBwjNJOLIgSzU2zqlfRm54VUmc+m7Quc2hlbGxzIE9C
UyBQcm9qZWN0IDxzaGVsbHNAYnVpbGQub3BlbnN1c2Uub3JnPohmBBMRAgAmBQJb
5mIWAhsDBQkYbra5BgsJCAcDAgQVAggDBBYCAwECHgECF4AACgkQhc/kUbkeHouX
KACZAS5MyfY0p8h9T2auwS9DmUBd7kEAn3S5tZ7vPMPdSPj0pTwJDhz5zMKJiEYE
ExECAAYFAkeWW10ACgkQOzARt2udZSMmKQCfSH+QgNSEDkhRcE/ALKh7jqA7zAsA
mgPnEw8AkhckGx4SM5o8gH6cDBq/
=ngPn
-----END PGP PUBLIC KEY BLOCK-----
EOF
rpm --import $t
rm -f $t

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

#=====================================
# Configure snapper
#-------------------------------------
if [ "$kiwi_btrfs_root_is_snapshot" = 'true' ]; then
        echo "creating initial snapper config ..."
        # we can't call snapper here as the .snapshots subvolume
        # already exists and snapper create-config doens't like
        # that.
        cp /etc/snapper/config-templates/default /etc/snapper/configs/root
        # Change configuration to match SLES12-SP1 values
        sed -i -e '/^TIMELINE_CREATE=/s/yes/no/' /etc/snapper/configs/root
        sed -i -e '/^NUMBER_LIMIT=/s/50/10/'     /etc/snapper/configs/root

        baseUpdateSysConfig /etc/sysconfig/snapper SNAPPER_CONFIGS root
fi


#=====================================
# Enable chrony if installed
#-------------------------------------
if [ -f /etc/chrony.conf ]; then
  # chronyc sits at 100% CPU even if chronyd service is disable
  # Looks like: https://github.com/balena-os/meta-balena/issues/1360
  # This should help once sorted; for now not installing chronyd (shame)
  # suseInsertService chronyd
  for i in 0 1 2 3; do
    echo "server $i.opensuse.pool.ntp.org iburst"
  done > /etc/chrony.d/opensuse.conf
fi

#=====================================
# Edit the base distro openSUSE license files in accordance with the following:
# https://en.opensuse.org/Archive:Making_an_openSUSE_based_distribution
# Files to edit /usr/share/licenses/openSUSE-release/*.txt
#
# test success via no output from:
# grep 'opensuse\|openSUSE\|OPENSUSE\|SUSE\|2008\|LLC' /usr/share/licenses/openSUSE-release/license.*
#-------------------------------------
shopt -s nullglob
for license_file in /usr/share/licenses/openSUSE-release/*.txt
do
    sed -i 's/openSUSE/Rockstor/g' "${license_file}"
    sed -i 's/OPENSUSE/ROCKSTOR/g' "${license_file}"
    sed -i 's/SUSE, LLC./Rockstor, Inc./g' "${license_file}"
    sed -i 's/SUSE، LLC./Rockstor, Inc./g' "${license_file}"  # Arabic comma (U+060C)
    sed -i 's/SUSE LLC/Rockstor, Inc./g' "${license_file}"
    sed -i 's/SUSE/Store Smartly/g' "${license_file}"
    sed -i 's/50/24/g' "${license_file}"
    sed -i 's/2008-2019/2012-2020/g' "${license_file}"
    sed -i 's/2008-2020/2012-2020/g' "${license_file}"  # presumably pending
    sed -i 's/http:\/\/en.opensuse.org\/Legal/http:\/\/rockstor.com\/legal.html/g' "${license_file}"
    sed -i 's/http:\/\/www.opensuse.org\/Legal/http:\/\/rockstor.com\/legal.html/g' "${license_file}"
done
# Alter the distro display name to add the suggested "Rockstor built on ..." prefix.
sed -i 's/PRETTY_NAME="openSUSE/PRETTY_NAME="Rockstor built on openSUSE/g' /usr/lib/os-release
# Alter BUG_REPORT_URL
sed -i 's/https:\/\/bugs.opensuse.org/https:\/\/forum.rockstor.com/g' /usr/lib/os-release
# Alter HOME_URL
sed -i 's/https:\/\/www.opensuse.org/http:\/\/rockstor.com/g' /usr/lib/os-release

#======================================
# Configure Raspberry Pi specifics
# from: https://build.opensuse.org/package/view_file/openSUSE:Factory:ToTest/kiwi-templates-JeOS/config.sh
#--------------------------------------
if [[ "$kiwi_profiles" == *"Leap15.2.RaspberryPi4"* ]]; then
  # Also show WLAN interfaces in /etc/issue
  baseUpdateSysConfig /etc/sysconfig/issue-generator NETWORK_INTERFACE_REGEX '^[bew]'

  # Add necessary kernel modules to initrd (will disappear with bsc#1084272)
  echo 'add_drivers+=" bcm2835_dma dwc2 "' > /etc/dracut.conf.d/raspberrypi_modules.conf

  # Work around network issues
  # Use tabs, "<<-" strips tabs, but no other whitespace!
  cat > /etc/modprobe.d/50-rpi3.conf <<-EOF
# Prevent too many page allocations (bsc#1012449)
options smsc95xx turbo_mode=N
EOF
  # Use tabs, "<<-" strips tabs, but no other whitespace!
  cat > /usr/lib/sysctl.d/50-rpi3.conf <<-EOF
# Avoid running out of DMA pages for smsc95xx (bsc#1012449)
vm.min_free_kbytes = 2048
EOF
fi

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

exit 0