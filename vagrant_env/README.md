Introduction
------------
You can use this vagrant environment to build the installer image within a vagrant box of a confirmed working 
specification.

Pre-requesits
-------------
It is assumped that you have the follow software packages install on you host machine:
- Vagrant (https://www.vagrantup.com/downloads)
- VirtualBox (https://www.virtualbox.org/wiki/Downloads)

The above packages are available on Linux, Mac OSX and Windows.

You will also need one of the following virtualisation platforms:
  - <b>Linux users:</b> may prefer to use libvirt, qemu + kxm (see https://github.com/vagrant-libvirt/vagrant-libvirt)

    or 
  - Virtualbox is available on all platforms (https://www.virtualbox.org/wiki/Downloads)

It is also assumed that you have a local copy of this repository [rockstor-installer](https://github.com/rockstor/rockstor-installer) 
on your machine, see the top level README.md, and are currently within the 'vagrant_env' directory: where the 
Vagrantfile, build.sh, and run_kiwi.sh are located.

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
- [opensuse/leap-15.2.x86_64](https://app.vagrantup.com/opensuse/boxes/Leap-15.2.x86_64)

or
- [opensuse/leap-15.2.aarch64](https://app.vagrantup.com/opensuse/boxes/Leap-15.2.aarch64)

eg.
```
v.vm.box = 'opensuse/Leap-15.2.x86_64' 
```

These boxes for vagrant are based on official images with the virtualisation tools added.  

Building the Rockstor ISO installer
-----------------------------------
On Mac OSX, Linux and Windows with Bash installed, execute the build script:

```shell script
./build.sh
```

This will, by default, build and provision an OpenSUSE Leap 15.2 vagrant box in libvirt.

Should you prefer to user virtual box you can perform the following:

```shell script
./build.sh virtualbox
```

On Windows without Bash installed, executed:

```
vagrant up --provider=virtualbox
vagrant ssh -c "cd /home/vagrant; /vagrant/run_kiwi.sh"
```

This will also build and provision the vagrant box. It will then run kiwi in the virtual machine to build the Rockstor 
Installer ISO. 

The resultant ISO will be available in this directory. (eg. ./rockstor-installer/vagrant_env)

Managing the Virtual Machine
----------------------------
To manage the Vagrant box VM simple type the following from this directory...

- Bring up a vagrant box VM
    ```shell script
    vagrant up --provider=libvirt
    ```
  or for virtual box
    ```shell script
    vagrant up --provider=virtualbox
    ```

- Reconfigure the vagrant box VM following a change to the Vagrantfile:
    ```shell script
    vagrant reload
    ```

- If you change the provisioner section of the Vagrantfile, you can rerun just that part as follows:
    ```shell script
    vagrant provision
    ```

- Destroy the vagrant box VM:
    ```shell script
    vagrant destroy
    ```

- If you wish to ssh into the vagrant box VM to poke around, try this:
    ```shell script
    vagrant ssh
    ```
