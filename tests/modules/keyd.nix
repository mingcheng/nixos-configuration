let
  t = import ../lib.nix;
  inherit (t) lib;
  config = t.eval [ ../../services/keyd.nix ];
  keyboards = config.services.keyd.keyboards;
  navigation = {
    b = "left";
    e = "end";
    f = "right";
    n = "down";
    p = "up";
  };
in
t.check "modules/keyd" {
  evaluates = t.validSystem config;
  enabled = config.services.keyd.enable && config.hardware.uinput.enable;
  device-groups =
    builtins.attrNames keyboards == [
      "0001-0001"
      "0fac-0ade"
    ];
  device-ids =
    keyboards."0001-0001".ids == [
      "0001:0001"
      "1fc9:e8d8"
    ]
    &&
      keyboards."0fac-0ade".ids == [
        "3151:4003"
        "0fac:0ade"
      ];
  caps-navigation = lib.all (
    keyboard:
    keyboard.settings.main.capslock == "overload(caps_control, esc)"
    && keyboard.settings."caps_control:C" == navigation
  ) (builtins.attrValues keyboards);
  primary-modifiers-unchanged =
    keyboards."0001-0001".settings.main == {
      capslock = "overload(caps_control, esc)";
    };
  external-modifiers =
    keyboards."0fac-0ade".settings.main == {
      capslock = "overload(caps_control, esc)";
      leftalt = "layer(meta)";
      rightalt = "rightmeta";
      leftmeta = "layer(alt)";
      rightmeta = "layer(altgr)";
    };
  managed-files-and-restarts = lib.all (
    name:
    builtins.hasAttr "keyd/${name}.conf" config.environment.etc
    &&
      builtins.elem config.environment.etc."keyd/${name}.conf".source
        config.systemd.services.keyd.restartTriggers
  ) (builtins.attrNames keyboards);
}
