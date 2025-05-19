# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 22nd 2022, 10:49:27 am
# Last Modified: Monday, August 22nd 2022, 10:49:28 am
#
# http://www.opensource.org/licenses/MIT

{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ../../nixconfig.nix
    ../../system/i18n.nix
    ../../system/sudo.nix
    ../../system/user.nix

    ../../services/fstrim.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix
    ../../services/docker.nix
    ../../services/sshd.nix
    #./apcupsd.nix

    ./packages.nix
    ../../packages/vim.nix

    ./boot.nix
    ./kernel.nix
    ./fs.nix
    ./zfs.nix
    ./networking.nix

    ./samba.nix
    ./nfs.nix
    #./mount.nix
  ];

  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = "192.168.0.4";
    devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" ];
  };

  services.prometheus.exporters.zfs = {
    enable = true;
    listenAddress = "192.168.0.4";
  };
}
