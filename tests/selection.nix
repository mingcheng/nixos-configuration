let
  t = import ./lib.nix;
  host = builtins.getEnv "NIX_BUILD_HOST";
  selected = builtins.tryEval (import ../main.nix);
  hosts = [
    "x1-carbon-8th"
    "vm-image"
    "usb-boot-stick"
  ];
  known = builtins.elem host hosts;
  hostDirectories = builtins.attrNames (
    t.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../hosts)
  );
  hostTests = map (t.lib.removeSuffix ".nix") (
    builtins.filter (t.lib.hasSuffix ".nix") (builtins.attrNames (builtins.readDir ./hosts))
  );
in
t.check "selection/${host}" {
  accepts-only-known-hosts = selected.success == known;
  returns-a-module = !selected.success || builtins.isFunction selected.value;
  all-hosts-covered =
    t.lib.sort builtins.lessThan hosts == hostDirectories
    && t.lib.sort builtins.lessThan hosts == hostTests;
}
