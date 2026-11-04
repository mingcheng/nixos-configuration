# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 29th 2022, 7:43:48 pm
# Last Modified: Monday, August 29th 2022, 7:45:34 pm
#
# http://www.opensource.org/licenses/MIT

{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../nixconfig.nix

    ../../system/boot.nix
    ../../system/fs.nix
    ../../system/i18n.nix
    ../../system/sudo.nix
    ../../system/user.nix

    ../../services/fstrim.nix
    ../../services/libvirtd.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix
    ../../services/sshd.nix

    ./kernel.nix
    ./networking.nix
    ./hostapd.nix
    ./bluetooth.nix
    ../chartman/packages.nix
    ../../packages/vim.nix
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
