{ configuration }:
let
  lib = import <nixpkgs/lib>;
  config =
    (import <nixpkgs/nixos/lib/eval-config.nix> {
      system = "x86_64-linux";
      modules = [ (builtins.toPath configuration) ];
    }).config;
  selectedUsers = config.workstation.users or [ ];
in
{
  toplevel = config.system.build.toplevel.drvPath;
  inherit (config) warnings;
  workstationUsers = selectedUsers;
  userPackages = lib.genAttrs selectedUsers (
    name: map lib.getName config.users.users.${name}.packages
  );
}
