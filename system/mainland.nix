# Mainland China mirrors for language package managers, imported by every host
# through profiles/base.nix. This is the only module that sets mirror variables
# or files; toolchain modules such as packages/golang.nix rely on it.
{ config, lib, ... }:
let
  mirrors = (import ../sources.nix).development;
  cargoConfig = "cargo/mainland.toml";
in
{
  # Nix propagates this to login sessions and the daemon. Go's fixed-output
  # dependency builders explicitly allow GOPROXY through impureEnvVars.
  # nix-daemon.nix copies nix.envVars into environment.sessionVariables at
  # normal priority, so a different session GOPROXY needs lib.mkForce.
  nix.envVars.GOPROXY = mirrors.goProxy;

  environment.sessionVariables = {
    GOSUMDB = lib.mkDefault mirrors.goSumdb;
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

    ${cargoConfig}.text = ''
      [source.crates-io]
      replace-with = "mainland"

      [source.mainland]
      registry = "${mirrors.cargoRegistry}"
    '';
  };

  # Cargo has no system-wide config search path and cannot set [source] tables
  # from CARGO_* environment variables, so link the mirror into the default
  # Cargo home of each workstation user at login. `L` never replaces an
  # existing ~/.cargo/config.toml; a custom CARGO_HOME or any other account
  # can still use `cargo --config /etc/cargo/mainland.toml`.
  systemd.user.tmpfiles.users = lib.genAttrs (config.workstation.users or [ ]) (_: {
    rules = [ "L %h/.cargo/config.toml - - - - /etc/${cargoConfig}" ];
  });
}
