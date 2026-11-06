let
  system = "x86_64-linux";
  pkgs = import <nixpkgs> {
    inherit system;
    config.allowUnfree = false;
  };
  inherit (pkgs) lib;
in
{
  inherit lib pkgs;

  eval =
    modules:
    (import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system pkgs;
      modules = [
        {
          system.stateVersion = "26.05";
          boot.loader.grub.enable = lib.mkDefault false;
          fileSystems = {
            "/" = {
              device = lib.mkDefault "/dev/disk/by-label/test-root";
              fsType = lib.mkDefault "ext4";
            };
            "/boot" = {
              device = lib.mkDefault "/dev/disk/by-label/test-efi";
              fsType = lib.mkDefault "vfat";
            };
            "/efi" = {
              device = lib.mkDefault "/dev/disk/by-label/test-efi";
              fsType = lib.mkDefault "vfat";
            };
          };
          swapDevices = lib.mkDefault [ { device = "/dev/disk/by-label/test-swap"; } ];
        }
      ]
      ++ modules;
    }).config;

  check =
    suite: tests:
    let
      failures = builtins.attrNames (lib.filterAttrs (_: passed: !passed) tests);
    in
    if failures == [ ] then
      {
        inherit suite;
        passed = builtins.attrNames tests;
      }
    else
      throw "${suite}: failed checks: ${lib.concatStringsSep ", " failures}";

  validSystem =
    config:
    builtins.seq config.system.build.toplevel.drvPath (
      if config.warnings == [ ] then
        true
      else
        throw "Unexpected NixOS warnings: ${lib.concatStringsSep "; " config.warnings}"
    );

  hasPackages =
    packages: names:
    let
      installed = map lib.getName packages;
    in
    lib.all (name: builtins.elem name installed) names;
}
