#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: samba-client.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-15 08:12:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-15 08:12:00
##

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.samba;
  settingsFormat = pkgs.formats.ini {
    listToValue = lib.concatMapStringsSep " " (lib.generators.mkValueStringDefault { });
  };
  clientConfigFile = settingsFormat.generate "smb-client.conf" {
    global = cfg.settings.global;
  };
in
{
  boot.supportedFilesystems.cifs = lib.mkDefault true;

  environment.systemPackages = [
    cfg.package
    pkgs.cifs-utils
  ]
  ++ lib.optionals config.services.desktopManager.plasma6.enable (
    with pkgs.kdePackages;
    [
      kio-extras
      kio-fuse
    ]
  );

  services.samba.settings.global = {
    workgroup = lib.mkDefault "WORKGROUP";
    "client min protocol" = lib.mkDefault "SMB2";
    "client max protocol" = lib.mkDefault "SMB3";
  };

  environment.etc."samba/smb.conf" = lib.mkIf (!cfg.enable) {
    source = lib.mkDefault clientConfigFile;
  };

  security.wrappers."mount.cifs" = lib.mkIf (!cfg.enable) {
    program = lib.mkDefault "mount.cifs";
    source = lib.mkDefault "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
    owner = lib.mkDefault "root";
    group = lib.mkDefault "root";
    setuid = lib.mkDefault true;
  };

  systemd.tmpfiles.rules = lib.mkIf (!cfg.enable) [
    "d /var/lock/samba 0755 root root - -"
    "d /var/cache/samba 0755 root root - -"
    "d /var/lib/samba 0755 root root - -"
    "d /run/samba 0755 root root - -"
  ];
}
