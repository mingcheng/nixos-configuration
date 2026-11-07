let
  t = import ./lib.nix;
  host = builtins.getEnv "NIX_BUILD_HOST";
  selected = builtins.tryEval (import ../main.nix);
  hostDirectories = builtins.attrNames (
    t.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../hosts)
  );
  known = builtins.elem host hostDirectories;
  hostTests = map (t.lib.removeSuffix ".nix") (
    builtins.filter (t.lib.hasSuffix ".nix") (builtins.attrNames (builtins.readDir ./hosts))
  );
in
t.check "selection/${host}" {
  accepts-only-known-hosts = selected.success == known;
  returns-a-module = !selected.success || builtins.isFunction selected.value;
  all-hosts-covered = hostDirectories == hostTests;
  all-hosts-have-entrypoints = t.lib.all (
    name: builtins.pathExists (../hosts + "/${name}/default.nix")
  ) hostDirectories;
}
