{ lib, ... }:
let
  mirrors = (import ../sources.nix).development;
in
{
  # Nix propagates this to login sessions and the daemon. Go's fixed-output
  # dependency builders explicitly allow GOPROXY through impureEnvVars.
  nix.envVars.GOPROXY = mirrors.goProxy;

  environment.sessionVariables = {
    # programs.npm.enable would also install Node.js in the system profile.
    NPM_CONFIG_GLOBALCONFIG = lib.mkDefault "/etc/npmrc";
    RUSTUP_DIST_SERVER = lib.mkDefault mirrors.rustupDistServer;
    RUSTUP_UPDATE_ROOT = lib.mkDefault mirrors.rustupUpdateRoot;
  };

  environment.etc = {
    "npmrc".text = ''
      registry=${mirrors.npmRegistry}
    '';
    "pip.conf".text = lib.generators.toINI { } {
      global.index-url = mirrors.pypiIndex;
    };
    "uv/uv.toml".text = ''
      [[index]]
      name = "mainland"
      url = "${mirrors.pypiIndex}"
      default = true
    '';

    # Cargo has no system-wide config search path; load this file with --config.
    "cargo/mainland.toml".text = ''
      [source.crates-io]
      replace-with = "mainland"

      [source.mainland]
      registry = "${mirrors.cargoRegistry}"
    '';
  };
}
