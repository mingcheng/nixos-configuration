#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: sshd.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 11:17:23 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-14 06:25:35
##

{ lib, ... }: {
  services.openssh = {
    enable = lib.mkDefault true;
    openFirewall = lib.mkDefault true;

    settings = {
      PubkeyAuthentication = true;
      AuthenticationMethods = "publickey";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = lib.mkDefault false;

      AllowAgentForwarding = lib.mkDefault true;
      AllowTcpForwarding = lib.mkDefault "yes";
      UseDns = lib.mkDefault false;

      LogLevel = lib.mkDefault "VERBOSE";
      LoginGraceTime = lib.mkDefault 60;
      MaxAuthTries = lib.mkDefault 3;
      MaxStartups = lib.mkDefault "10:30:30";
      ClientAliveInterval = lib.mkDefault 60;
      ClientAliveCountMax = lib.mkDefault 5;
    };
  };
}
