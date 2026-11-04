#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# http://www.opensource.org/licenses/MIT
#
# File: main.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 11:17:42 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 15:09:25
##

let
  host = builtins.getEnv "NIX_BUILD_HOST";
  hostConfiguration = name: ./hosts + "/${name}/default.nix";
  availableHosts = builtins.filter (name: builtins.pathExists (hostConfiguration name)) (
    builtins.attrNames (builtins.readDir ./hosts)
  );
  hostHint = "Available hosts: ${builtins.concatStringsSep ", " availableHosts}.";
in
if host == "" then
  throw "NIX_BUILD_HOST is not set. ${hostHint}"
else if !(builtins.elem host availableHosts) then
  throw "Unknown NIX_BUILD_HOST '${host}'. ${hostHint}"
else
  {
    imports = [ (hostConfiguration host) ];

    environment.variables = {
      NIX_BUILD_HOST = host;
      HOSTNAME = host;
    };
  }
