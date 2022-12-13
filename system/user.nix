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
      extraGroups = [ "wheel" "libvirtd" "docker" ];
      shell = pkgs.bash;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXDVd4hh3dGu8sq5HC0KGC3WKkn4+5tecgxksL4JL43 mingcheng@wildfire.local"
      ];
    };
  };
}
