#!/bin/bash

# https://osinside.github.io/kiwi/concept_and_workflow/shell_scripts.html
# "The pre_disk_sync.sh can be used to change content of the root tree
# as a last action before the sync to the disk image is performed."

#======================================
# SELinux config - if installed
#--------------------------------------
# `enforcing=0` for permissive (default), 1 for enforcing
selinuxcmdline=('security=selinux' 'selinux=1')
# SELinux kernel options added to rockstor.kiwi image.preferences.type kernelcmdline= entries.
if [[ -e /etc/selinux/config ]]; then
    # Grub kernel cmdline additions
    if [[ -e /etc/default/grub ]]; then
        sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=\"|&${selinuxcmdline[*]} |" /etc/default/grub
    fi
    # Sysconfig bootloader cmdline additions (installer boot)
    if [[ -e /etc/sysconfig/bootloader ]]; then
        sed -i "s|^DEFAULT_APPEND=\"|&${selinuxcmdline[*]} |" /etc/sysconfig/bootloader
        sed -i "s|^FAILSAFE_APPEND=\"|&${selinuxcmdline[*]} |" /etc/sysconfig/bootloader
    fi
    # SELinux config
    sed -i -e 's|^SELINUX=.*|SELINUX=permissive|g' \
           -e 's|^SELINUXTYPE=.*|SELINUXTYPE=targeted|g' \
           "/etc/selinux/config"
fi
