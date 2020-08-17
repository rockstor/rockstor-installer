Introduction
------------
You can use this vagrant environment to build the installer image within a vagrant box of a confirmed working 
specification.

Pre-requesits
-------------
It is assumped that you have the follow software packages install on you host machine:
- Vagrant (https://www.vagrantup.com/downloads)
- VirtualBox (https://www.virtualbox.org/wiki/Downloads)

Both packages are available on Linux, Mac OSX and Windows.

Configuring
-----------
To configure the environment to build the required platform/profile you need to edit both the following files to 
comment/uncomment the 'PROFILE' variable to the desired value:

- Vagrantfile
- run_kiwi.sh

Building the RockStor ISO installer
-----------------------------------
On Mac OSX, Linux and Windows with Bash installed, execute the build script:

```shell script
./build.sh
```

On Windows without Bash installed, executed:

```
vagrant up
vagrant ssh -c cd "/home/vagrant; /vagrant/run_kiwi.sh"
```

This will also build and provision the vagrant box. It will then run kiwi in the virtual machine to build the RockStor 
Installer ISO.

Managing the Virtual Machine
----------------------------
To manage the Vagrant box VM simple type the following from this directory...

- Bring up a vagrant box VM
```shell script
vagrant up
```

- Reconfigure the vagrant box VM following a change to the Vagrantfile:

```shell script
vagrant reload
```

- Destroy the vagrant box VM:

```shell script
vagrant destroy -f
```
