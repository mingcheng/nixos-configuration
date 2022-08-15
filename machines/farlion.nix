{ config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../nixconfig.nix

    ../system/autoupdate.nix
    ../system/env.nix
    ../system/i18n.nix
    ../system/misc.nix
    ../system/sudo.nix
    ../system/user.nix
    ../system/shell.nix
    ./farlion.d/networking.nix

    ./farlion.d/openssh.nix
    ../services/timesyncd.nix
    ../services/docker.nix

    ../packages/default.nix
    ../packages/kubectl.nix
    ../packages/netutils.nix
    # ../packages/fish.nix
    ../packages/dev.nix
    # ../packages/vim.nix
    ../packages/nvim.nix
    ../packages/git.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    options = ["defaults" "discard" "noatime"];
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;
}
