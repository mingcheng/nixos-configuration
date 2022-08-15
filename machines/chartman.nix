{ config, lib, ... }: {
  imports = [
    ../nixconfig.nix

    ../hardware-configuration.nix
    ./chartman.d/kernel.nix

    ../system/fs.nix
    ../system/autoupdate.nix
    ../system/boot.nix
    ../system/env.nix
    ../system/i18n.nix
    ../system/misc.nix
    ./chartman.d/networking.nix
    ../system/sudo.nix
    ../system/user.nix
    ../system/shell.nix

    ../services/apcupsd.nix
    ../services/libvirtd.nix
    ./chartman.d/openssh.nix
    ../services/timesyncd.nix
    ../services/fstrim.nix

    ../packages/default.nix
    ../packages/fish.nix
    ../packages/vim.nix
    ../packages/nvim.nix
    ../packages/git.nix
  ];
}
