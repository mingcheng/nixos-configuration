/*
  * File: openssh.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  *
  * Created Date: Sunday, August 14th 2022, 11:58:49 pm
  * Last Modified: Monday, August 15th 2022, 12:02:15 am
  *
  * http://www.opensource.org/licenses/MIT
*/

{ config, pkgs, lib, ... }:
{
  services.openssh = lib.mkForce {
    enable = true;
    listenAddresses = [{
      addr = "172.16.0.201";
      port = 22;
    }];

    passwordAuthentication = false;
    permitRootLogin = "no";
  };
}
