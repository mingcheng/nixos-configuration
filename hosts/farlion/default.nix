# File: farlion.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 15th 2022, 9:48:13 am
# Last Modified: Monday, August 15th 2022, 4:03:28 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, config, lib, modulesPath, ... }: {
  imports = [
    ../qemu
    ../../nixconfig.nix

    ../../system/env.nix
    ../../system/misc.nix
    ../../system/shell.nix

    ../../services/timesyncd.nix
    ../../services/docker.nix

    ../../packages/kubectl.nix
    ../../packages/netutils.nix
    # ../../packages/fish.nix
    ../../packages/golang.nix
    # ../../packages/vim.nix
    ../../packages/nvim.nix
    ../../packages/git.nix

    ./networking.nix
    ./openssh.nix
    ./packages.nix

    ../../services/postgresql.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    neededForBoot = true;
    options = [ "defaults" "discard" "noatime" ];
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;
}
