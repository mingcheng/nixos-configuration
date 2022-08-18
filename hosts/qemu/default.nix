{ config, pkgs, lib, modulesPath, ... }: {

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./udev.nix
    ../../system/i18n.nix
    ../../system/networking.nix
    ../../system/sudo.nix
    ../../system/user.nix
    ../../services/openssh.nix
  ];

  #    boot.kernel.sysctl."kernel.yama.ptrace_scope" = mkOverride 500 1;
}
