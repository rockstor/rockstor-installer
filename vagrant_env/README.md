Introduction
------------
You can use this vagrant environment to build the installer image within a vagrant box of a confirmed working 
specification.

Pre-requisites
-------------
The following software packages should be installed on the host machine:
- Vagrant (https://www.vagrantup.com/downloads)
- VirtualBox (https://www.virtualbox.org/wiki/Downloads)
- Oracle VM VirtualBox Extension Pack (https://www.virtualbox.org/wiki/Downloads)

Both packages/extensions are available on Linux, Mac OSX and Windows.

Also, a local copy of this repository [rockstor-installer](https://github.com/rockstor/rockstor-installer) on your machine, see the top level README.md, and are currently within the `vagrant_env` directory: where the `Vagrantfile`, `build.sh`, and `run_kiwi.sh` are located.

A few notes on the processing flow:
- Before bringing up the vagrant box, make adjustments to either of these files and also edit the `rockstor.kiwi` in the parent directory according to the options to be used (see top-level README.md).
- Because the shared folder between the host and the VirtualBox VM cannot be accessed correctly by the KVM that the boxbuild generates, the 'run_kiwi.sh' file will be copied into the box from the host directory at the end of the vagrant box activation, so any changes should be done beforehand.
- The `run_kiwi.sh` file in turn will then copy the `rockstor.kiwi` file into a fresh copy of the repository directly on the vagrant box, which is then accessible by the 'kiwi-ng' generated KVM.
- At the end of the boxbuild process, the files in the resulting output directory will be copied back into the host directory, so they can then be used without having to be logged into the vagrant box. The final steps clean up the repository and the directory holding the iso file. This way a new build with other settings in `rockstor.kiwi` can be executed without having to recreate the vagrant box from scratch.

Configuring Profiles
--------------------
NOTE: Currently, only the x86_64 profile is usable due to the availability of suitable vagrant boxes for 
AArch64 in VirtualBox. 

<s>
To configure the environment to build the required platform/profile you need to edit both the following files to 
comment/uncomment the 'PROFILE' variable to the desired value:

- Vagrantfile
- run_kiwi.sh
</s>

Vagrant Boxes for OpenSUSE Leap
-------------------------------

This vagrant file uses the vagrant boxes: 
- [opensuse/leap-15.3.x86_64](https://app.vagrantup.com/opensuse/boxes/Leap-15.3.x86_64) or
- [opensuse/leap-15.3.aarch64](https://app.vagrantup.com/opensuse/boxes/Leap-15.3.aarch64)

which can be found in the `Vagrantfile` under this setting:
```
v.vm.box = 'opensuse/Leap-15.3.x86_64' 
```

These boxes for vagrant are based on official images with the virtualisation tools added.

Note: in some instances when VirtualBox Guest Additions are not the same on the VirtualBox installation and the OpenSUSE image, problems can occur. In the Vagrantfile there is an option to edit (comment/uncomment) a bento based vagrant box of the LEAP OS, which has shown to work as well in a cinch.

Building the Rockstor ISO installer
-----------------------------------
As indicated in the top-level readme, make adjustments to the 'rockstor.kiwi' in the top-level directory (e.g. `rockstor-installer`) before returning to the `vagrant-env` directory and initiate the rockstor ISO build.

On Mac OSX, Linux and Windows with Bash installed, execute the build script:

```shell script
./build.sh
```
On Windows without Bash installed, execute:

```
vagrant up
vagrant ssh -c "./run_kiwi.sh"
```

This will build and provision the vagrant box. It will then run kiwi in the virtual machine to build the Rockstor 
Installer ISO.

The resultant ISO will be available in this directory. (e.g., ./rockstor-installer/kiwi-images)

Managing the Virtual Machine
----------------------------
To manage the Vagrant box VM simple type the following from the directory where the respective vagrant file is located (in this case it would be the vagrant_env folder)

- Bring up a vagrant box VM

```shell script
vagrant up
```
- Stop the vagrant box VM

```shell script
vagrant halt
```

- Reconfigure the vagrant box VM following a change to the Vagrantfile:

```shell script
vagrant reload
```

- If you change the provisioner section of the Vagrantfile, you can rerun just that part as follows:

```shell script
vagrant provision
```
- or if the current vagrant box is still running:

```shell script
vagrant reload --provision
```
- Destroy the vagrant box VM:

```shell script
vagrant destroy
```

- If you wish to ssh into the vagrant box VM to poke around, try this:

```shell script
vagrant ssh
```
