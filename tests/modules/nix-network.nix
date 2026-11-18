let
  t = import ../lib.nix;
  inherit (t) lib;
  sources = import ../../sources.nix;
  cargoLink = "L %h/.cargo/config.toml - - - - /etc/cargo/mainland.toml";
  config = t.eval [ ../../profiles/base.nix ];
  changed = t.eval [
    ../../profiles/base.nix
    {
      environment.sessionVariables = {
        # nix.envVars defines GOPROXY at normal priority (see system/mainland.nix).
        GOPROXY = lib.mkForce "https://proxy.golang.org,direct";
        GOSUMDB = "sum.golang.org";
        NPM_CONFIG_GLOBALCONFIG = "/etc/custom-npmrc";
        RUSTUP_DIST_SERVER = "https://rust.example.test";
        RUSTUP_UPDATE_ROOT = "https://rust.example.test/rustup";
      };
    }
  ];
  workstationUsers = t.eval [
    ../../profiles/base.nix
    ../../packages/user-packages.nix
    {
      workstation.users = [
        "alice"
        "bob"
      ];
      users.users = {
        alice.isNormalUser = true;
        bob.isNormalUser = true;
        carol.isNormalUser = true;
      };
    }
  ];
in
t.check "modules/nix-network" {
  evaluates = t.validSystem config;
  overrides-evaluate = t.validSystem changed && t.validSystem workstationUsers;
  caches-have-one-source = config.nix.settings.substituters == sources.substituters;
  signed-substitutes = config.nix.settings.require-sigs;
  bounded-downloads =
    config.nix.settings.fallback
    && config.nix.settings.connect-timeout == 5
    && config.nix.settings.stalled-download-timeout == 30
    && config.nix.settings.download-attempts == 3;
  garbage-collection =
    config.nix.gc.automatic
    && config.nix.gc.dates == [ "weekly" ]
    && config.nix.gc.options == "--delete-older-than 30d";
  trusted-wheel =
    lib.sort builtins.lessThan config.nix.settings.trusted-users == [
      "@wheel"
      "root"
    ];
  locale =
    config.time.timeZone == "Asia/Shanghai"
    && config.i18n.defaultLocale == "en_US.UTF-8"
    && builtins.elem "zh_CN.UTF-8/UTF-8" config.i18n.supportedLocales;
  sudo-policy = config.security.sudo.execWheelOnly && !config.security.sudo.wheelNeedsPassword;
  go-proxy =
    config.nix.envVars.GOPROXY == sources.development.goProxy
    && config.environment.sessionVariables.GOPROXY == sources.development.goProxy
    && config.environment.sessionVariables.GOSUMDB == sources.development.goSumdb
    && config.systemd.services.nix-daemon.environment.GOPROXY == sources.development.goProxy;
  no-implicit-http-proxy = !(config.systemd.services.nix-daemon.environment ? http_proxy);
  npm-registry =
    config.environment.sessionVariables.NPM_CONFIG_GLOBALCONFIG == "/etc/npmrc"
    && lib.hasInfix "registry=${sources.development.npmRegistry}" config.environment.etc.npmrc.text;
  pip-index = lib.hasInfix sources.development.pypiIndex config.environment.etc."pip.conf".text;
  uv-index = lib.hasInfix sources.development.pypiIndex config.environment.etc."uv/uv.toml".text;
  cargo-registry =
    lib.hasInfix sources.development.cargoRegistry config.environment.etc."cargo/mainland.toml".text
    && lib.hasInfix ''replace-with = "mainland"'' config.environment.etc."cargo/mainland.toml".text
    # Cargo ignores [source] tables in environment variables.
    && !(lib.any (lib.hasPrefix "CARGO_") (builtins.attrNames config.environment.sessionVariables));
  cargo-mirror-link =
    config.systemd.user.tmpfiles.users == { }
    && workstationUsers.environment.etc ? "cargo/mainland.toml"
    && workstationUsers.systemd.user.tmpfiles.users.alice.rules == [ cargoLink ]
    && workstationUsers.systemd.user.tmpfiles.users.bob.rules == [ cargoLink ]
    && !(workstationUsers.systemd.user.tmpfiles.users ? carol)
    && t.hasPackages workstationUsers.users.users.alice.packages [ "nixos-user-tmpfiles.d-alice" ]
    && workstationUsers.users.users.carol.packages == [ ];
  rustup-mirrors =
    config.environment.sessionVariables.RUSTUP_DIST_SERVER == sources.development.rustupDistServer
    && config.environment.sessionVariables.RUSTUP_UPDATE_ROOT == sources.development.rustupUpdateRoot;
  mirrors-overridable =
    changed.environment.sessionVariables.GOPROXY == "https://proxy.golang.org,direct"
    && changed.systemd.services.nix-daemon.environment.GOPROXY == sources.development.goProxy
    && changed.environment.sessionVariables.GOSUMDB == "sum.golang.org"
    && changed.environment.sessionVariables.NPM_CONFIG_GLOBALCONFIG == "/etc/custom-npmrc"
    && changed.environment.sessionVariables.RUSTUP_DIST_SERVER == "https://rust.example.test"
    && changed.environment.sessionVariables.RUSTUP_UPDATE_ROOT == "https://rust.example.test/rustup";
  nsncd-no-dns-restarts = config.networking.resolvconf.extraConfig == "libc_restart=':'";
}
