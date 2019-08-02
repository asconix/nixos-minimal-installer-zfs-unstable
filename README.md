This repository contains a build script that creates a custom NixOS installation image. The result contains zfsUnstable that is required in NixOS 19.03 to use the native ZFS encryption.

To create a custom NixOS install image we need an existing NixOS environment. Just launch the following command:

```
NIX_PATH=nixpkgs=channel:nixos-unstable:nixos-config=$PWD/zfsUnstable.nix nix-build --no-out-link '<nixpkgs/nixos>' -A config.system.build.isoImage
```

