let
  t = import ../lib.nix;
  inherit (t) lib pkgs;
  sources = import ../../sources.nix;
  config = t.eval [ ../../system/network_hosts.nix ];
  local_file = pkgs.writeText "local_test_hosts" "192.0.2.10 extra.example.test\n";
  changed = t.eval [
    ../../system/network_hosts.nix
    {
      networking = {
        hosts."192.0.2.11" = [ "lan.example.test" ];
        extraHosts = "192.0.2.12 manual.example.test";
        hostFiles = [ local_file ];
      };
    }
  ];
  headless = t.eval [ ../../profiles/base.nix ];
  host_paths = cfg: map toString cfg.networking.hostFiles;
  remote_paths = map (url: toString (builtins.fetchurl url)) sources.hosts;
in
t.check "modules/network_hosts" {
  evaluates = t.validSystem config;
  overrides_evaluate = t.validSystem changed;
  no_native_blocklist =
    !config.networking.stevenblack.enable && !changed.networking.stevenblack.enable;
  sources_are_urls = lib.all builtins.isString sources.hosts;
  remote_files_included = lib.all (path: builtins.elem path (host_paths config)) remote_paths;
  system_host_files_preserved =
    lib.all (name: lib.any (path: lib.hasSuffix "-${name}" path) (host_paths config))
      [
        "localhost-hosts"
        "string-hosts"
        "extra-hosts"
      ];
  no_stale_github_override = config.networking.extraHosts == "";
  local_entries_preserved =
    changed.networking.hosts."192.0.2.11" == [ "lan.example.test" ]
    && changed.networking.extraHosts == "192.0.2.12 manual.example.test\n";
  additional_files_merge =
    builtins.elem (toString local_file) (host_paths changed)
    && lib.all (path: builtins.elem path (host_paths changed)) remote_paths;
  headless_unchanged =
    !headless.networking.stevenblack.enable
    && lib.all (path: !(builtins.elem path (host_paths headless))) remote_paths;
}
