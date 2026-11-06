{ config, lib, ... }:
let
  cfg = config.workstation;
in
{
  options.workstation = {
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Existing normal users receiving shared desktop and development applications.";
    };

    userPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Applications installed only for the users selected by workstation.users.";
    };
  };

  config = {
    warnings = lib.optional (cfg.users == [ ] && cfg.userPackages != [ ]) (
      "workstation.userPackages: packages are configured but workstation.users is empty; "
      + "select existing normal users to install these applications."
    );

    assertions = map (name: {
      assertion = config.users.users.${name}.isNormalUser or false;
      message = "workstation.users: '${name}' must be declared with users.users.${name}.isNormalUser = true.";
    }) cfg.users;

    users.users = lib.genAttrs cfg.users (_: {
      packages = cfg.userPackages;
    });
  };
}
