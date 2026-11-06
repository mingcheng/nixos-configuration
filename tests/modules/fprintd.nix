let
  t = import ../lib.nix;
  inherit (t) lib;
  config = t.eval [
    ../../services/fprintd.nix
    {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
      security.pam.services = {
        login.rules.auth.unix.settings.nodelay = lib.mkForce true;
        custom-password = { };
        custom-fingerprint.fprintAuth = true;
      };
    }
  ];
  headless = t.eval [ ../../services/fprintd.nix ];
  pam = config.security.pam.services;
in
t.check "modules/fprintd" {
  evaluates = t.validSystem config;
  tty-fingerprint = pam.login.fprintAuth && lib.hasInfix "pam_fprintd.so" pam.login.text;
  password-required = !pam.login.allowNullPassword && !pam.kde.allowNullPassword;
  sddm-password-only =
    !pam.sddm.fprintAuth
    && !pam.sddm.rules.auth.login.enable
    && !(lib.hasInfix "pam_fprintd.so" pam.sddm.text)
    && !(lib.hasInfix "nullok" pam.sddm.text);
  login-arguments-copied-once = lib.count (arg: arg == "nodelay") pam.sddm.rules.auth.unix.args == 1;
  lock-screen-password = !pam.kde.fprintAuth && !(lib.hasInfix "pam_fprintd.so" pam.kde.text);
  lock-screen-fingerprint =
    pam.kde-fingerprint.fprintAuth && lib.hasInfix "pam_fprintd.so" pam.kde-fingerprint.text;
  pam-default-opt-out = !pam.sudo.fprintAuth && !pam.custom-password.fprintAuth;
  pam-explicit-opt-in = pam.custom-fingerprint.fprintAuth;
  enrollment-authorization =
    lib.hasInfix "subject.local" config.security.polkit.extraConfig
    && lib.hasInfix "subject.active" config.security.polkit.extraConfig
    && lib.hasInfix "polkit.Result.AUTH_ADMIN" config.security.polkit.extraConfig;
  no-headless-desktop-pam =
    !(headless.security.pam.services ? sddm) && !(headless.security.pam.services ? kde-fingerprint);
}
