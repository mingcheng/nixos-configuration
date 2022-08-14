{ config, lib, ... }: {
  imports = [
    ../hardware-configuration.nix
    ../nixconfig.nix
    ../hardware/fs.nix

    ../system/autoupdate.nix
    ../system/boot.nix
    ../system/env.nix
    ../system/i18n.nix
    ../system/misc.nix
    ../system/networking.nix
    ../system/sudo.nix
    ../system/user.nix
    ../system/shell.nix

    ../services/apcupsd.nix
    ../services/libvirtd.nix
    ../services/openssh.nix
    ../services/timesyncd.nix
    ../services/fstrim.nix

    ../packages/default.nix
    ../packages/fish.nix
    ../packages/vim.nix
    ../packages/nvim.nix
    ../packages/git.nix
  ];

  services.openssh = lib.mkForce {
    enable = true;
    listenAddresses = [{
      addr = "192.168.0.8";
      port = 22;
    }];

    # passwordAuthentication = true;
    # permitRootLogin = "yes";
  };

  networking = {
    hostName = "chartman";

    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;

    interfaces = {
      "br0" = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.0.8";
          prefixLength = 23;
        }];
      };
    };

    bridges = {
      "br0" = { interfaces = [ "enp1s0f0" "enp1s0f1" "enp1s0f2" "enp1s0f3" ]; };
    };

    defaultGateway = "192.168.1.254";
    nameservers = [ "192.168.1.254" ];
  };
}
