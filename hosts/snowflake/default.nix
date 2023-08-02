# File: farlion.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 15th 2022, 9:48:13 am
# Last Modified: Monday, August 15th 2022, 4:03:28 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, modulesPath, pkgs, ... }: {
  imports = [
    ../qemu
    ../../nixconfig.nix

    ../../services/timesyncd.nix
    ../../services/docker.nix

    ../../packages/kubectl.nix
    ../../packages/netutils.nix
    ../../packages/golang.nix
    ../../packages/nvim.nix
    ../../packages/git.nix

    ../farlion/packages.nix
    ./networking.nix
    ./fs.nix
    ./samba.nix
    #    ./davfs2.nix
    ./firewall.nix
    ./fail2ban.nix
    ../farlion/ld.nix
    ./docker.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    neededForBoot = true;
    options = [ "defaults" "discard" "noatime" ];
  };

  # boot.kernelPackages = pkgs.linuxPackages_5_18;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;
}
