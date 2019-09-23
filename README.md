# NixOS minimal installer with zfsUnstable

This repository contains a build script that creates a custom NixOS installation image. The result image contains `zfsUnstable` that is required in NixOS 19.03 to use the native ZFS encryption. It also contains `dialog` since it is required by our custom installer.

To create a custom NixOS install image we either need an existing NixOS environment or at least VirtualBox on our machine.

## Existing NixOS environment

If you already run a NixOS instance, just launch the following command:

```
NIX_PATH=nixpkgs=channel:nixos-19.03:nixos-config=./custom.nix nix-build --no-out-link '<nixpkgs/nixos>' -A config.system.build.isoImage
```

## VirtualBox

If you don't have access to a NixOS instance, the easiest way is to run the build in a virtual machine. To achieve this you need VirtualBox installed.

First of all download the VirtualBox appliance:

```
curl -O https://releases.nixos.org/nixos/19.03/nixos-19.03.173522.021d733ea3f/nixos-19.03.173522.021d733ea3f-x86_64-linux.ova
```

Next start Virtualbox and import the OVA file for the downloaded VirtualBox appliance via `File` -> `Import Appliance`.

Next go into `Machine` -> `Settings`, then `System` and set `Base memory` to 4096 MB. We will need a decent portion of memory to rebuild our system.

Next go into `Machine` -> `Settings`, then `Network` -> `Adapter 1`  and set `Attached to` to `Bridged adapter`. Next go into `Advanced` and ensure that `Cable Connected` is checkeed.

Next start the machine, and wait for it to boot. You can login at the graphical login screen with username `demo` and password `demo`.

When the desktop appears, open a terminal and launch the following commands:
 
```
sudo su -
nixos-generate-config --force
```

The command above writes two configuration files `/etc/nixos/configuration.nix` and `/etc/nixos/hardware-configuration.nix`.
 
We need to make two changes in the configuration file `/etc/nixos/configuration.nix`. First of all we need to define on which partition we want to install Grub. To achieve this uncomment the line 20:

```
boot.loader.grub.device = "/dev/sda";
``` 
 
To login later via SSH into our virtual machine we need to enable SSH daemon in `/etc/nixos/configuration.nix`. First of all add the `lib` namespace in line 5:
 
```
{ config, lib, pkgs, ...}:
``` 
Next uncomment line 53:

```
services.openssh.enable = true;
```

... and add two new lines 54-55:

```
services.openssh.permitRootLogin = "yes";
systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
```

Next change root password:

```
passwd
```

Finally we need to rebuild our NixOS instance and activate it:

```
nixos-rebuild switch
```

After NixOS has been rebuilt, we need to install git manually:

```
nix-env -iA nixos.gitMinimal
```

Next clone the Git repository that contains the custom image builder:

```
git clone https://github.com/cpilka/nixos-minimal-installer-zfs-unstable.git
```

Finally build the custom install image by launching the following command:

```
cd nixos-minimal-installer-zfs-unstable
NIX_PATH=nixpkgs=channel:nixos-19.03:nixos-config=./custom.nix nix-build --no-out-link '<nixpkgs/nixos>' -A config.system.build.isoImage
```

The NixOS image will be stored in `/nix/store`, in our case in `/nix/store/82vhvmc5pr6kcn3g13v2plfya0p1wrd3-nixos-19.03.173522.021d733ea3f-x86_64-linux.iso/iso/nixos-19.03.173522.021d733ea3f-x86_64-linux.iso`.

# Create USB stick

Next we need to create a bootable USB stick. I assume, our USB disk is assigned to `/dev/disk3`. Please check your device file by executing:

```
$ diskutil list
```

In our case we get some partition details as feedback:

```
/dev/disk3 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *128.8 GB   disk3
   1:               Windows_NTFS                         128.8 GB   disk3s1
```

Create the USB stick by wiping all existing data:

```
$ diskutil eraseDisk FAT32 NIXOS_ISO MBRFormat /dev/disk3
```

You should get a feedback message similar to:

```
Started erase on disk3
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk3s1 as MS-DOS (FAT32) with name NIXOS_ISO
512 bytes per physical sector
/dev/rdisk3s1: 251596736 sectors in 3931199 FAT32 clusters (32768 bytes/cluster)
bps=512 spc=64 res=32 nft=2 mid=0xf8 spt=32 hds=255 hid=2 drv=0x80 bsec=251658238 bspf=30713 rdcl=2 infs=1 bkbs=6
Mounting disk
Finished erase on disk3
```

Next unmount the USB stick:

```
$ diskutil unmountDisk /dev/disk3
```

... which should return:

```
Unmount of all volumes on disk3 was successful
```

Next copy blockwise the ISO image to the USB stick:

```
$ sudo dd bs=4m if=nixos-19.03.173238.4b6dd53b90a-x86_64-linux.iso of=/dev/rdisk3
```

After the password has been entered, the file is copied:

```
130+0 records in
130+0 records out
545259520 bytes transferred in 9.411540 secs (57935208 bytes/sec)
```

At this point we have created an USB thumb drive that is bootable by any computer. We will use this USB stick to bootstrap our NixOS machines.

See the ISO image in the [release section](https://github.com/cpilka/nixos-minimal-installer-zfs-unstable/releases) of the Git repository. It contains the most recent and downloadable version of the NixOS 19.03 installer (stable) at time of writing this README (4th August 2019).
