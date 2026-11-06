let
  t = import ../lib.nix;
  inherit (t) lib;
  sources = import ../../sources.nix;
  config = t.eval [ ../../profiles/base.nix ];
  changed = t.eval [
    ../../profiles/base.nix
    {
      environment.sessionVariables = {
        NPM_CONFIG_GLOBALCONFIG = "/etc/custom-npmrc";
        RUSTUP_DIST_SERVER = "https://rust.example.test";
        RUSTUP_UPDATE_ROOT = "https://rust.example.test/rustup";
      };
    }
  ];
in
t.check "modules/nix-network" {
  evaluates = t.validSystem config;
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
    && config.systemd.services.nix-daemon.environment.GOPROXY == sources.development.goProxy;
  no-implicit-http-proxy = !(config.systemd.services.nix-daemon.environment ? http_proxy);
  npm-registry =
    config.environment.sessionVariables.NPM_CONFIG_GLOBALCONFIG == "/etc/npmrc"
    && lib.hasInfix "registry=${sources.development.npmRegistry}" config.environment.etc.npmrc.text;
  pip-index = lib.hasInfix sources.development.pypiIndex config.environment.etc."pip.conf".text;
  uv-index = lib.hasInfix sources.development.pypiIndex config.environment.etc."uv/uv.toml".text;
  cargo-registry =
    lib.hasInfix sources.development.cargoRegistry config.environment.etc."cargo/mainland.toml".text
    && !(config.environment.sessionVariables ? CARGO_HOME);
  rustup-mirrors =
    config.environment.sessionVariables.RUSTUP_DIST_SERVER == sources.development.rustupDistServer
    && config.environment.sessionVariables.RUSTUP_UPDATE_ROOT == sources.development.rustupUpdateRoot;
  mirrors-overridable =
    changed.environment.sessionVariables.NPM_CONFIG_GLOBALCONFIG == "/etc/custom-npmrc"
    && changed.environment.sessionVariables.RUSTUP_DIST_SERVER == "https://rust.example.test"
    && changed.environment.sessionVariables.RUSTUP_UPDATE_ROOT == "https://rust.example.test/rustup";
}
