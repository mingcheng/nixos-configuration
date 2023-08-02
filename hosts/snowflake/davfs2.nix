# File: samba.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 6:34:09 pm
# Last Modified: Thursday, August 18th 2022, 6:34:09 pm
#
# http://www.opensource.org/licenses/MIT

{ config, lib, pkgs, ... }:

{
  services.davfs2 = {
    enable = true;
    extraConfig = ''
      use_locks 1
    '';
  };

  environment.etc = {
    "davfs2/secrets" = {
      text = ''
        http://172.16.0.201:5244/dav admin kiYn8sIo
      '';
      mode = "0600";
    };
  };
}
