# File: default.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 22nd 2022, 10:49:27 am
# Last Modified: Monday, August 22nd 2022, 10:49:28 am
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

    ../../services/fstrim.nix
    ../../services/prometheus.nix
    ../../services/timesyncd.nix
    ../../services/docker.nix
    ../../services/sshd.nix
    ../wooramel/apcupsd.nix

    ./kernel.nix
    ./networking.nix
    ./zfs.nix
    ./nfs.nix
    ../wooramel/packages.nix
    ../../packages/vim.nix
  ];
}
