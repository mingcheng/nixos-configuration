# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Friday, August 26th 2022, 11:50:34 am
# Last Modified: Friday, August 26th 2022, 11:50:36 am
#
# http://www.opensource.org/licenses/MIT

{ config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../nixconfig.nix

    ../../system/boot.nix
    ../../system/fs.nix
    ../../system/i18n.nix
    ../../system/sudo.nix
    ../../system/user.nix
    ../../system/networking.nix

    ../../services/fstrim.nix
    ../../services/libvirtd.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix
    ../../services/sshd.nix

    ./kernel.nix
    ./network.nix
    ../chartman/packages.nix
    ../../packages/vim.nix
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
