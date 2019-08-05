{ config, lib, pkgs, ... }: {
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix> ];
  
  boot.zfs.enableUnstable = true;
}

