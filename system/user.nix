# File: user.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:17:23 pm
# Last Modified: Monday, August 15th 2022, 10:43:44 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }: {
  users = {
    users.mingcheng = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "libvirtd" "docker" "network" "davfs2" ];
      shell = pkgs.bash;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXDVd4hh3dGu8sq5HC0KGC3WKkn4+5tecgxksL4JL43 mingcheng@wildfire.local"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzDRMyiKFNeZPwbmftFJbboao72npOuvdjOHoMkjNwiz4ozpj6wuZexZZZgwVqb+fiBB777S7PYzYiqyyLPTT00xuskMH53XaNHehFglyPQocOWL5s0x63MNnVu9JIxBG4QirR2oinWVlXh7w6b3IJM2km0vNxvtlQmiVXVj3vZaS+nEicM8DlqOByHf/hRP8S77r1vlmR+kb1gJ1bVc/7ZDkgk40ZyFA9IMgSbXLhx4cJ0c9yBiK/upW4uqPYInSYOSozxX+/k2tjLhH1AEd74YBh541H7xzp2y2a6FSvIkllCVgJPz5Ya5MeSCUyrqPUkrzM4GhEhrYEammpR8bP9M60bE6+DJeNBEbH2HIQisavIXYoE60FOMk7hiL5uxxxUltrWOxPYhlPLGOTruTafxhwhttOa0S/KSfLL2Uip5+rkhvbofWg9JAAvyoikbWO8xBHkm5JwpzdRpcMtWsMJjIGxBQX4YckHcDOjeQmuqPnENv8lfNxLAZidii/BmSGgToJKtWEv2oqFqXkzW3a77m2DDLT8yxKHpXmHSHLPny8SCmRYjJEcM1MmFcLQJO1cZlhrYayblgU0uK3cVjDNU5qPkJ4VnDDH5OBhCclIDN25WvRKK5yiB6O2auDQ+A894nuxEXcZW6oSqRR/407/60Yce/PKphXn5cbn0cDxw== mingcheng@surface.local"
      ];
    };
  };
}
