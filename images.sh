#!/bin/bash

# https://osinside.github.io/kiwi/concept_and_workflow/shell_scripts.html
# "Executed at the beginning of the image creation process.
# It runs in the same image root tree created by the prepare step,
# but it is invoked whenever an image needs to be created from that root tree.
# It is normally used to apply image type specific changes to the root tree,
# such as a modification to a config file that must be done when building a live iso,
# but not when building a virtual disk image."

# https://osinside.github.io/kiwi/concept_and_workflow.html#the-create-step
# "At the beginning of the image creation process the script named images.sh is executed (if present)."

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
