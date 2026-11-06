{ configuration }:
let
  config =
    (import <nixpkgs/nixos/lib/eval-config.nix> {
      system = "x86_64-linux";
      modules = [ (builtins.toPath configuration) ];
    }).config;
in
{
  toplevel = config.system.build.toplevel.drvPath;
  inherit (config) warnings;
}
