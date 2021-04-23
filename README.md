
# Rockstor 4 Installer Recipe

This repo contains the [kiwi-ng](https://github.com/OSInside/kiwi) configuration used to create Rockstor 4 'Built on openSUSE' installers.
Please see the excellent [kiwi ng docs](https://osinside.github.io/kiwi/) for configuration options.

Pull requests most welcome; especially new target system profiles.
Please test your modifications on all affected profiles prior to submission and provide details of how you tested the resulting installer.

## Profile Anatomy
Profiles are named after their upstream distribution base, i.e. openSUSE Leap version, and then the intended target system; the two elements separated by a ".".

The "target system" element is either generic, i.e. **x86_64** or **AArch64**, or target system specific, i.e. **RaspberryPi4** or **ARM64EFI**.
With the latter ARM64EFI spanning both generic (Arm64) and specific (64 bit EFI).

## Core Profiles
Our current intention is to distribute pre-built installers, pending any trademark prerequisites, made from the following profiles:

- **Leap15.2.x86_64**
- **Leap15.2.RaspberryPi4**
- **Leap15.2.ARM64EFI**

These will be linked to from our [Downloads](http://rockstor.com/download.html) page upon reaching our first Rockstor 4 Stable release.

## Contributing a Profile
If you would like to add a specific target system installer profile, please take a look at the [examples](https://github.com/OSInside/kiwi-descriptions) referenced in the second link above.
The rockstor.kiwi file itself also contains comments with links to example configs used during it's development. 
We can make no promises for the 'supported' status of any additional profiles but '[The Rockstor Project](http://rockstor.com/about-us.html)' will endeavour to make available the more popular resulting installers, in binary form, pending Trademark prerequisites etc.

## Current Profiles

### Working Profiles:
- **Leap15.2.x86_64** (recommended) - proposed for our Rockstor 4 're-launch')
- **Leap15.2.RaspberryPi4**
- **Leap15.2.ARM64EFI**

#### Raspberry Pi4 Notes:
As we are attempting to stick as closely as possible to upstream, and have limited resources, this installer requires
the recent Raspberry OS initiated firmware updates and associated /boot files copied over to enable USB boot.
See later "AArch64 host ..." section for more details.
However, regular microSD card boot should work out-of-the-box.

### Broken Profiles
Prior to Tumbleweed dropping some Python 2 libraries this profile was functional.
We used this target to inform our developmental direction and as a more leading-edge installer option. 
We are preserving this profile for when our in-process Python 2 to 3 move is complete.

### Special mention:
- Leap15.2.ARM64EFI

We are very exited to welcome contributions for the innovative [Traverse Ten64](https://www.crowdsupply.com/traverse-technologies/ten64) AArch64 platform.
[Traverse technologies](https://traverse.com.au/) are an important contributor to the [rockstor-core](https://github.com/rockstor/rockstor-core) code base
and have been instrumental in achieving our initial AArch64 aims.
Although this profile includes Ten64 specific drivers (inactive on non Ten64 platforms), it is otherwise a modern generic Arm64 installer.
The resulting installer is intended to supports 64-bit ARM systems that implement the [Embedded Boot](https://github.com/ARM-software/ebbr) or [Server boot](https://github.com/ARM-software/sbsa-acs) standard. 

## HOWTO

Please see the [overview](https://osinside.github.io/kiwi/overview.html) section of the kiwi-ng docs for the canonical
[System Requirements](https://osinside.github.io/kiwi/overview.html#system-requirements): e.g. 15 GB free space, Python 3.5+ etc.

Given our image target OS is exclusively 'Built on openSUSE', a vanilla openSUSE Leap 15.2 install is recommended as the kiwi-ng host operating system.

### rockstor-installer local copy

In order to build the installer you need a local copy of the [rockstor-installer](https://github.com/rockstor/rockstor-installer) GitHub repository.
This README.md file is part of that repository.
To get this copy you simply need to 'git clone' that repository to your local openSUSE instance:

```shell script
zypper in git
git clone https://github.com/rockstor/rockstor-installer.git
cd rockstor-installer/
```  

The above commands installs the 'git' program, uses it to 'clone' (read copy locally) the GitHub repo, and sets your working directory to be inside the local copy.
Now you just need the kiwi-ng program this config requires to make the final installer. 

### kiwi-ng install
For an openSUSE Leap 15.2 OS from kiwi-ng's doc [Installation](https://osinside.github.io/kiwi/installation.html#installation) section we have:


#### x86_64 host for x86_64 profiles
Any x86_64 machine, although keep in mind that building the ISO installer is computationally expensive so Haswell or better is recommended.
```shell script
sudo zypper addrepo http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.2/ appliance-builder
sudo zypper install python3-kiwi btrfsprogs gfxboot
```

#### AArch64 host (e.g. a Pi4) for AArch64 profiles
See [HCL:Raspberry Pi4](https://en.opensuse.org/HCL:Raspberry_Pi4). Install, for example, an appliance JeOS Leap 15.2 image as the host OS.
Enabling USB boot on the Pi4 will allow for the use of, for example, an SSD as the system drive which will massively speed up installer building.
This will likely require a bootloader update via a fully updated Raspberry OS and copying the resulting /boot/start4* and /boot/fixup4*
files from that OS over the ones found in the JeOS Leap 15.2 /EFI dir. The same procedure may also be required for USB booting the resulting Rockstor installer.
Depending on upstream updates, and the existing version of your Pi4 bootloader, neither step may be necessary.

Pi4 EEPROM/bootloader version "Jun 15 2020" or later will be required for USB boot regardless of any installer /EFI file changes.
   
```shell script
sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.2_ARM/ appliance-builder
sudo zypper install python3-kiwi btrfsprogs
```

### Edit rockstor.kiwi
Edit all lines directly preceeded by **<!-- Change to ...** to reflect your chosen profile any rockstor rpm version changes you make.
These edits are done automatically by our release infrastructure but are required when exucuting by hand, as in this HowTo.

### Warning
It is recommended that a discrete OS install is used to build the Rockstor installer due to the root user requirement and the scope of operations performed.
We hope later to transition to a newer mechanism within kiwi-ng where by KVM is employed to create the required build environment.
Any assistance with this endeavour would be much appreciated. See: kiwi-ng's new [boxbuild](https://osinside.github.io/kiwi/self_contained.html) capability.   

### Leap15.2.x86_64 profile
Executed, as the root user, in the directory containing this repositories rockstor.kiwi file.
```shell script
kiwi-ng --profile=Leap15.2.x86_64 --type oem system build --description ./ --target-dir /home/kiwi-images/
```

### Leap15.2.RaspberryPi4 profile
Executed, as the root user, in the directory containing this repositories rockstor.kiwi file.
```shell script
kiwi-ng --profile=Leap15.2.RaspberryPi4 --type oem system build --description ./ --target-dir /home/kiwi-images/
```

## Resulting Rockstor installers
With the above suggested kiwi-ng commands the resulting installers will be found in **/home/kiwi-images/** on the kiwi-ng host systems.

- For the x86_64 profiles the resulting installer is an ISO image intended for image transfer to an installer only device.
Use the file ending in ".iso".
- For the RaspberryPi4 profile the resulting installer is an uncompressed raw disk image intended for image transfer to the target system disk directly.
Use the file ending in ".raw".

The resulting installs will grow, on first boot, to the size of their host devices.
All partitioning is fully automatic.
Please see [Rockstor’s “Built on openSUSE” installer](http://rockstor.com/docs/installer-howto/installer-howto.html) HowTo for a user guide.

## Help or Assistance
Our [friendly forum](https://forum.rockstor.com/) is a good place to ask question regarding this HowTo.
Please be patient however as our support is predominantly community based and the above newly released procedure is not yet well known or tested by our community members.
If you find an issue with this procedure and it's associated kiwi-ng config, please consider submitting a pull request with any fixes or improvements you consequently discover or invent.

'The Rockstor Project' is a community endeavour and depends on [update channel](http://rockstor.com/docs/update-channels/update_channels.html)
subscriptions and contributions for it's continued open source development.  




