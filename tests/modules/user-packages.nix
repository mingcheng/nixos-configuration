let
  t = import ../lib.nix;
  inherit (t) lib pkgs;
  empty = t.eval [ ../../packages/user-packages.nix ];
  unassigned = t.eval [
    ../../packages/user-packages.nix
    { workstation.userPackages = [ pkgs.jq ]; }
  ];
  selected = t.eval [
    ../../packages/user-packages.nix
    {
      workstation = {
        users = [
          "alice"
          "bob"
        ];
        userPackages = [ pkgs.jq ];
      };
      users.users = {
        alice = {
          isNormalUser = true;
          packages = [ pkgs.tree ];
        };
        bob.isNormalUser = true;
        other.isNormalUser = true;
      };
    }
  ];
  missing = t.eval [
    ../../packages/user-packages.nix
    { workstation.users = [ "missing" ]; }
  ];
  root = t.eval [
    ../../packages/user-packages.nix
    { workstation.users = [ "root" ]; }
  ];
  rejectsUser =
    config:
    lib.any (
      assertion: !assertion.assertion && lib.hasPrefix "workstation.users:" assertion.message
    ) config.assertions
    && !(builtins.tryEval config.system.build.toplevel.drvPath).success;
in
t.check "modules/user-packages" {
  empty-evaluates = t.validSystem empty;
  selected-evaluates = t.validSystem selected;
  no-default-user =
    empty.workstation.users == [ ]
    && lib.filterAttrs (_: user: user.isNormalUser) empty.users.users == { };
  unassigned-packages-warn = lib.any (lib.hasPrefix "workstation.userPackages: packages are configured but workstation.users is empty;") unassigned.warnings;
  unassigned-packages-remain-opt-in = builtins.seq unassigned.system.build.toplevel.drvPath (
    unassigned.workstation.users == [ ]
    && lib.filterAttrs (_: user: user.isNormalUser) unassigned.users.users == { }
    && !(t.hasPackages unassigned.environment.systemPackages [ "jq" ])
  );
  all-selected-users = t.hasPackages selected.users.users.bob.packages [ "jq" ];
  host-packages-merge = t.hasPackages selected.users.users.alice.packages [
    "jq"
    "tree"
  ];
  unselected-users-untouched = selected.users.users.other.packages == [ ];
  no-global-applications = !(t.hasPackages selected.environment.systemPackages [ "jq" ]);
  no-implicit-privileges =
    selected.users.users.alice.extraGroups == [ ]
    && !(builtins.elem "alice" selected.nix.settings.trusted-users);
  missing-user-rejected = rejectsUser missing;
  root-user-rejected = rejectsUser root;
}
