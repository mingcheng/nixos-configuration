# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Friday, August 26th 2022, 11:50:34 am
# Last Modified: Friday, August 26th 2022, 11:50:36 am
#
# http://www.opensource.org/licenses/MIT

{
  config,
  lib,
  modulesPath,
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
    ../../system/networking.nix

    ../../services/fstrim.nix
    ../../services/libvirtd.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix
    ../../services/sshd.nix
    ../../services/apcupsd.nix

    ./kernel.nix
    ./networking.nix
    ../chartman/packages.nix
    ../../packages/vim.nix
  ];

  powerManagement = {
    enable = true;
    #cpuFreqGovernor = lib.mkDefault "performance";
    #cpuFreqGovernor = lib.mkDefault "powersave";
    cpuFreqGovernor = lib.mkDefault "ondemand";
    cpufreq = {
      max = 1800000;
      min = 800000;
    };
  };

  # https://serverfault.com/questions/616485/e1000e-reset-adapter-unexpectedly-detected-hardware-unit-hang
  # https://superuser.com/questions/1270723/how-to-fix-eth0-detected-hardware-unit-hang-in-debian-9
  # https://www.reddit.com/r/NixOS/comments/cg102t/comment/eudvtz1/?context=3

  systemd.services.fix-e1000e = {
    serviceConfig.Type = "oneshot";
    script = ''
      sleep 30

      /run/current-system/sw/bin/ethtool -K enp3s0f0 gso off gro off tso off
      /run/current-system/sw/bin/ethtool -K enp3s0f0 tx off rx off

      /run/current-system/sw/bin/ethtool -K enp3s0f1 gso off gro off tso off
      /run/current-system/sw/bin/ethtool -K enp3s0f1 tx off rx off

      /run/current-system/sw/bin/ethtool -K enp4s0f0 gso off gro off tso off
      /run/current-system/sw/bin/ethtool -K enp4s0f0 tx off rx off

      /run/current-system/sw/bin/ethtool -K enp4s0f1 gso off gro off tso off
      /run/current-system/sw/bin/ethtool -K enp4s0f1 tx off rx off

      echo OK > /tmp/fix-e1000e.txt
    '';

    # https://unix.stackexchange.com/questions/619848/how-can-i-list-all-of-the-systemd-targets
    # systemctl list-units --type target
    wantedBy = [ "multi-user.target" ];
  };
}
