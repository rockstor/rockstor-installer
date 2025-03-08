
# Rockstor "Built on openSUSE" Installer Recipe

This repo contains the [kiwi-ng](https://github.com/OSInside/kiwi) configuration used to create Rockstor 'Built on openSUSE' installers.
Please see the excellent [kiwi ng docs](https://osinside.github.io/kiwi/) for configuration options.

Pull requests most welcome; especially new target system profiles.
Please test your modifications on all affected profiles prior to submission and provide details of how you tested the resulting installer.

## Profile Anatomy
Profiles are named after their upstream distribution base, i.e. openSUSE Leap version,
and then the intended target system; with the two elements separated by a ".".

The "target system" element is either generic, i.e. **x86_64** or **AArch64**, or target system specific, i.e. **RaspberryPi4** or **ARM64EFI**.
With the latter ARM64EFI spanning both generic (Arm64) and specific (64 bit EFI).

## Core Profiles
Our current pre-built installers are built using the following profiles (see: [Downloads](https://rockstor.com/dls.html)):

- **Leap15.6.x86_64**
- **Leap15.6.RaspberryPi4**
- **Leap15.6.ARM64EFI**
- **Slowroll.x86_64**
- **Tumbleweed.x86_64**
- **Tumbleweed.RaspberryPi4**
- **Tumbleweed.ARM64EFI**

### Pi4 USB boot
USB booting on the Pi4 may require a bootloader update via a fully updated Raspberry OS.
Pi4 EEPROM/bootloader version "Jun 15 2020" or later will be required for USB boot,
regardless of any installer/EFI file changes.

### Special mention
- ARM64EFI

We are fortunate & thankful to have had contributions from/for the innovative [Traverse Ten64](https://www.crowdsupply.com/traverse-technologies/ten64) AArch64 platform.
[Traverse technologies](https://traverse.com.au/) have been instrumental in achieving our initial AArch64 compatibility aims.
The resulting installer is intended to support 64-bit ARM systems that implement the [Embedded Boot](https://github.com/ARM-software/ebbr) or [Server boot](https://github.com/ARM-software/sbsa-acs) standard.
Note that additional drives may be required for your specific hardware,
if so consider [Installing the Stable Kernel Backport](https://rockstor.com/docs/howtos/stable_kernel_backport.html).
Also see the following subsection for enabling these same repositories/facilities within the resulting installer itself.

## Contributing a Profile
If you would like to add a specific target system installer profile,
please take a look at the [examples](https://github.com/OSInside/kiwi-descriptions) referenced in the second link above.
The `rockstor.kiwi` file itself also contains comments with links to example configs used during its development. 
We can make no promises for the 'supported' status of any additional profiles,
but '[The Rockstor Project](https://rockstor.com/about-us.html)' will endeavour to make available the more popular resulting installers.
See our [Community Contributions](https://rockstor.com/docs/contribute_section.html) doc section for an overview to contributing,
and the [howto subsection](#howto) below to test proposed changes. 

## HOWTO

Please see the [kiwi-ng docs overview](https://osinside.github.io/kiwi/overview.html) for the canonical
[System Requirements](https://osinside.github.io/kiwi/overview.html#system-requirements) for building the installer:
e.g., 15 GB free space, Python version, etc.
It is recommended to use at least Kiwi-ng v10.1.18 to build our [Core Profiles](#core-profiles).

Given our profiles' target OSs are exclusively 'Built on openSUSE',
a vanilla openSUSE Leap 15.5/6 instance is recommended if not using the kiwi-ng boxbuild method.
But if the newer kiwi-ng boxbuild method in "Building on any linux host... " is used,
any relatively modern linux system can be used to build the installer.

### rockstor-installer local copy

In order to build the installer you need a local copy of the [rockstor-installer](https://github.com/rockstor/rockstor-installer) GitHub repository.
This README.md file is part of that repository.
To get this copy you simply need to 'git clone' that repository to your local openSUSE instance:

```shell
zypper in git
git clone https://github.com/rockstor/rockstor-installer.git
cd rockstor-installer/
```  

The above commands install the 'git' program, and use it to 'clone' (read copy locally) the GitHub repo,
before setting your working directory to be inside this local copy.
Now you just need the kiwi-ng program this config requires to make the actual installer. 

### Building on any linux host (KVM support required)
Kiwi now has support for using KVM virtual machines to build in an isolated environments, regardless of the linux host.

With the release of version 10.x of `kiwi ng` the minimum required python version is now `3.9` or higher.
On any linux platform with KVM virtualization enabled and the corresponding python3 version,
you can use an isolated python virtual environment to build the installer without modifying your host OS,
or needing to manually set up an openSUSE virtual machine (see below for this alternative).
This boxbuild approach does have some overheads compared to building on a baremetal installation,
but on reasonably powerful hardware it can still take less than twenty minutes.

By default, the kiwi-boxed-plugin will reserve 8GB of memory, and 4 CPU cores.
This can be modified with `--box-memory=<vm>G --box-smp-cpus=<number>`, e.g., `--box-memory 4G --box-smp-cpus=2`.
On machines with low RAM, building with as low as 1GB has been tested successfully.
Assigning too much RAM will crash your host, so be sure to set a safe amount smaller than your current available host ram.
Arguments before the `--` are passed to boxbuild, and after are passed to the kiwi-ng build itself.

**Note on using a host OS within a Virtual Machine:**
If using a Linux OS in a Virtual Machine,
any shared folders from the host are not properly recognized by the KVM/QEMU that is generated by `kiwi-ng`'s boxbuild approach.
This can lead to `chroot` errors and terminate the installer generation.
The recommendation in this case is to clone the installer git directly into the VM directory,
and edit the relevant files (e.g., `rockstor.kiwi`) before executing the box build.
Or to edit them outside of the VM and transfer them back into the VM's installer directory using a shared folder.
At the end of installer creation the `.iso` file must then be copied from within the VM directory back onto the VM's host for further use.

**Note on `pip` usage:**
Some distros might still have a split between Python 2.x/3.x usage of `pip` (i.e. pip3 vs. pip),
or an existing system that is being used had both installed over time.
If that is the case, one wants to ensure that the 3.x version is used, by explicitly declaring `pip3` in the below command line. 
Otherwise, this can lead to execution errors down the line.

```shell
python3 -m venv kiwi-env
```

**Note on virtual environment with a specific python3 version:**
In case multiple python3 versions are installed (e.g., 3.11 was added to enable the usage of `kiwi`),
the `venv` should be created using the specific version.
Otherwise, the kiwi and box-plugin versions will revert to a lower version than 10x.
Therefore, unless the higher python3 version has been set up to be the default version,
the virtual environment should be created (using the example of version `3.11`):

```shell
python3.11 -m venv kiwi-env
```

If the system/distro has dropped python 2.x support, or if it is not installed on the system that is used for the build:
```shell
./kiwi-env/bin/pip install kiwi kiwi-boxed-plugin
```
Or go with the explicit version 3.x of pip:
```shell
./kiwi-env/bin/pip3 install kiwi kiwi-boxed-plugin
```
The rest remains the same (make sure to consider the memory and CPU defaults mentioned above)
```shell
./kiwi-env/bin/kiwi-ng --profile=Leap15.5.x86_64 --type oem \
  system boxbuild --box leap -- --description ./ --target-dir ./images
```

### For building on dedicated openSUSE installations
This was the preferred method before the above kiwi-ng boxbuild capability existed.

#### kiwi-ng install
For an openSUSE Leap 15.5/6 OS from kiwi-ng's doc [Installation](https://osinside.github.io/kiwi/installation.html#installation) section we have:

#### x86_64 host for x86_64 profiles
Any x86_64 machine, keeping in mind that building an installer is computationally expensive,
so systems with a decent-sized CPU/RAM combination released in the last 5-7 years is recommended.

##### Leap 15.5/6 host
The openSUSE host version should ideally be at least the version of the target profile.
Since Leap 15.5/6 ships with a default `python 3.6x` it is necessary to install a higher python version (e.g., `3.11`):

```shell
sudo zypper in python311
```

then add the required repository:

for 15.5:

```shell
sudo zypper addrepo http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.5/ appliance-builder
```

or for 15.6

```shell
sudo zypper addrepo https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6/ appliance-builder
```

and install kiwi and the additional requirements as shown below:

```shell
sudo zypper install python3-kiwi btrfsprogs gfxboot qemu-tools gptfdisk e2fsprogs squashfs xorriso dosfstools
```

#### AArch64 host (e.g., a Pi4) for AArch64 profiles
See [HCL:Raspberry Pi4](https://en.opensuse.org/HCL:Raspberry_Pi4).
Install, for example, an appliance JeOS Leap 15.5/6 image as the host OS.
Enabling USB boot on older Pi4 systems will allow for the use of, for example,
an SSD as the system drive which will massively speed up installer building.
See [Pi4 USB boot](#pi4-usb-boot).

### Edit rockstor.kiwi
No edit is required if you wish to use the generic installer filename and default rockstor package version (recommended).
To change these defaults edit all lines directly preceded by **<!--Change to ...** as per the **...** details given.
Our release infrastructure performs these same edits to set official installer filenames and rockstor package versions.

#### Stable Kernel Backport & matching btrfs-progs
To enable the use of 'Stable Kernel Backport' and 'filesystems' repositories within our `rockstor.kiwi` config,
uncomment the corresponding repositories.
For more information about using the most recent kernels see
[Installing the Stable Kernel Backport](https://rockstor.com/docs/howtos/stable_kernel_backport.html).

#### Root disk LUKS encryption
If you want to enable LUKS encryption of the Root disk (where Rockstor is installed),
uncomment the relevant parameters available as example in the **Leap15.5.x86_64** profile.
This will enable `LUKS2` encryption and utilize PBKDF2, as grub does not yet support the more recent `argon2id` algorithm.

N.B.: The `luksformat` parameter's preceding hyphens have to be escaped to exist as a comment.
When adding more non-commented parameters,
the required double-hyphens can be inserted without escaping them to their Unicode character codes.

### Leap15.6.x86_64 profile
Executed, as the root user, in the directory containing this repository's `rockstor.kiwi` file.

```shell
kiwi-ng --profile=Leap15.6.x86_64 --type oem system build --description ./ --target-dir /home/kiwi-images/
```

### Leap15.6.RaspberryPi4 profile
Executed, as the root user, in the directory containing this repository's `rockstor.kiwi` file.

```shell
kiwi-ng --profile=Leap15.6.RaspberryPi4 --type oem system build --description ./ --target-dir /home/kiwi-images/
```

## Resulting Rockstor installers
With the above suggested `kiwi-ng` commands the resulting installers will be found in **/home/kiwi-images/** on the kiwi-ng host systems.

- For the x86_64 profiles the resulting installer is an ISO image intended for image transfer to an installer only device.
Use the file ending in ".iso".
- For the RaspberryPi4 profile the resulting installer is an uncompressed raw disk image intended for image transfer to the target system disk directly.
Use the file ending in ".raw".

The resulting installs will grow on first boot to the size of their host devices.
All partitioning is fully automatic.

Please see [Rockstor’s “Built on openSUSE” installer](https://rockstor.com/docs/installer-howto/installer-howto.html) How-to for a user guide.

## Help or Assistance
Our [friendly forum](https://forum.rockstor.com/) is a good place to ask question regarding this How-to.
If you enable any of the above described enhancements i.e. backported kernel, LUKS, or add other options,
be sure to include their details when reporting any problems.
Please be patient as our support is community based and the above procedures are always in-flux/development.

If you find an issues with these instructions, or the kiwi-ng config,
please consider creating an issue and submitting a pull request with a proposed fix.

[The Rockstor Project](https://opencollective.com/the-rockstor-project) is an [Open Collective](https://opencollective.com/)
Non-Profit/Non-Business Open Source community endeavour.
As such it depends on subscriptions and contributions for its sustainability.

