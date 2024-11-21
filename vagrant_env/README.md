Introduction
------------
You can use a vagrant environment to build the installer image within a vagrant box of a confirmed working specification.


Pre-requisites
-------------
The following software packages should be installed on the host machine:
- Vagrant (https://www.vagrantup.com/downloads)
- VirtualBox and the  VirtualBox Extension Pack (https://www.virtualbox.org/wiki/Downloads)

Both packages/extensions are available on Linux, Mac OSX and Windows.

Also, a local copy of this repository [rockstor-installer](https://github.com/rockstor/rockstor-installer) on your machine, see the top level README.md, and are currently within the `vagrant_env` directory: where the `Vagrantfile`, `initial_prep.sh`, `build.sh`, and `run_kiwi.sh` are located.

A few notes on the processing flow:
- Before bringing up the vagrant box, make adjustments to either of these files and also edit the `rockstor.kiwi` in the parent directory according to the options to be used (see top-level README.md).
- At the end of the build process, the files in the resulting output directory will be copied back into the host directory, so they can then be used without having to be logged into the vagrant box. The final steps clean up the repository and the directory holding the iso file. This way a new build with other settings in `rockstor.kiwi` can be repeatedly executed without having to recreate the vagrant box from scratch.

Configuring Profiles
--------------------
NOTE: Currently, only the x86_64 profile is usable due to the lack of availability of suitable vagrant boxes for 
aarch64 in VirtualBox (the ones listed below for `aarch64` could be used if `libvirt` is the provider).

To configure the environment to build the required platform/profile you need to edit `run_kiwi.sh` file to and update the 'PROFILE' variable to the desired value

Vagrant Boxes for OpenSUSE Leap
-------------------------------

This vagrant file uses the vagrant boxes: 
- [opensuse/leap-15.6.x86_64](https://portal.cloud.hashicorp.com/vagrant/discover/opensuse/Leap-15.6.x86_64) or
- [opensuse/Tumbleweed.x86_64](https://portal.cloud.hashicorp.com/vagrant/discover/opensuse/Tumbleweed.x86_64)

only if using `libvirt` as the provider (untested in this set of instructions):
- [opensuse/leap-15.6.aarch64](https://portal.cloud.hashicorp.com/vagrant/discover/opensuse/Leap-15.6.aarch64)
- [opensuse/Tumbleweed.aarchx64](https://portal.cloud.hashicorp.com/vagrant/discover/opensuse/Tumbleweed.aarch64)

If necessary, adjust these settings in the `Vagrantfile`:
```
  config.vm.box = "opensuse/Leap-15.6.x86_64"
  config.vm.box_version = "15.6.13.356" 
```
The values can be derived from the listed vagrant box, when looking at the `Option` boxes on the right-hand side on the vagrant box web page.
Depending on the host system used for this, also adjust the number of CPUs and memory (in MB) in the file.
Save and place the vagrant file in a directory where the vagrant instance should be brought up.


Prepare the Vagrant Virtual Machine (using VirtualBox as provider)
------------------------------------------------------------------
Assuming that the Vagrant box directory essentially has the same directory structure and files as the `rockstor-installer` repo, and the Vagrant file was manually copied from the `vagrant_env` directory to the level above, change the directory to where the `Vagrantfile` is located.

Execute (under windows)
```shell script
vagrant up
```

To ensure that the latest openSUSE patches and kiwi-ng pre-requisites are installed. For that activity run the script:
```shell script
vagrant ssh -c "/vagrant/vagrant_env/initial_prep.sh"
```
The default passwords to `ssh` into the vagrant box is `vagrant`.

For the openSUSE patches, there is user confirmation is required, but the remainder of the updates should work without interaction. If during the update of the openSUSE packages a kernel update was performed, a reboot of the vagrant box will be required before continuing, using:

```shell script
vagrant reload
```

If the same vagrant virtual machine is going to be used some time later again for other builds, the above script can be rerun to ensure the latest packages are installed.
Alternatively, one can enter the running machine with `vagrant ssh` and then run e.g. `sudo zypper up` and potentially reboot the virtual machine before proceeding to building a new iso.




Building the Rockstor ISO installer
-----------------------------------
As indicated in the top-level readme, make any desired adjustments to the `rockstor.kiwi` in the top-level directory (e.g., `../rockstor-installer`) before initiating the rockstor ISO build.
If not currently running, bring up the vagrant box with `vagrant up` (Note: make sure this is run in the top-level directory where the vagrant box was originally started from!).

On Mac OSX, Linux and Windows with Bash installed, execute the build script:

```shell script
./vagrant_env/build.sh
```
On Windows without Bash installed, execute:

```shell script
vagrant ssh -c "/vagrant/run_kiwi.sh"
```

This will then run kiwi-ng in the virtual machine to build the Rockstor installer ISO.

The resultant ISO will be available in the top-level directory outside of the virtual machine. (e.g., `../rockstor-installer/kiwi-images`).



Managing the Virtual Machine
----------------------------
To manage the Vagrant box VM simply type the following from the directory where the respective vagrant file is located (e.g., `../rockstor-installer`)

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