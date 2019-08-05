# NixOS minimal installer with zfsUnstable

This repository contains a build script that creates a custom NixOS installation image. The result contains zfsUnstable that is required in NixOS 19.03 to use the native ZFS encryption.

To create a custom NixOS install image we either need an existing NixOS environment or at least VirtualBox on our machine.

## Existing NixOS environment

If you already run a NixOS instance, just launch the following command:

```
NIX_PATH=nixpkgs=channel:nixos-unstable:nixos-config=./custom.nix nix-build --no-out-link '<nixpkgs/nixos>' -A config.system.build.isoImage
```

## VirtualBox

If you don't have access to a NixOS instance, the easiest way is to run the build in a virtual machine. To achieve this you need VirtualBox installed.

First of all download the VirtualBox appliance:

```
curl -O https://releases.nixos.org/nixos/19.03/nixos-19.03.173214.4cc5592fe2d/nixos-19.03.173214.4cc5592fe2d-x86_64-linux.ova
```

Next start Virtualbox and import the OVA file for the downloaded VirtualBox appliance via `File` -> `Import Appliance`.

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
