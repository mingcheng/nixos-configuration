{ config, lib, modulesPath, ... }: {
  system.stateVersion = "22.05"; # Did you read the comment?

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
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;

  services.openssh = lib.mkForce {
    enable = true;
    listenAddresses = [{
      addr = "192.168.0.11";
      port = 22;
    }];

    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  networking = {
    hostName = "farlion";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "enp7s0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.11";
          prefixLength = 23;
        }];
      };
    };

    defaultGateway = "192.168.1.254";
    nameservers = [ "192.168.1.254" ];
  };
}
