# NixOS minimal installer with zfsUnstable

This repository contains a build script that creates a custom NixOS installation image. The result contains zfsUnstable that is required in NixOS 19.03 to use the native ZFS encryption.

To create a custom NixOS install image we either need an existing NixOS environment or at least VirtualBox on our machine.

## Existing NixOS environment

If you already run a NixOS instance, just launch the following command:

```
NIX_PATH=nixpkgs=channel:nixos-unstable:nixos-config=$PWD/zfsUnstable.nix nix-build --no-out-link '<nixpkgs/nixos>' -A config.system.build.isoImage
```

## VirtualBox

If you haven't access to a NixOS instance, the easiest way is to run the build in a virtual machine. To achieve this you need VirtualBox installed.

First of all download the VirtualBox appliance:

```
curl -O https://releases.nixos.org/nixos/19.03/nixos-19.03.173214.4cc5592fe2d/nixos-19.03.173214.4cc5592fe2d-x86_64-linux.ova
```

... and import it into VirtualBox (`File` -> `Impoort Appliance`).
