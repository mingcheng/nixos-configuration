let
  t = import ../lib.nix;
  sources = import ../../sources.nix;
  config = t.eval [
    ../../packages/atuin.nix
    ../../packages/bat.nix
    ../../packages/fish.nix
    ../../packages/git.nix
    ../../packages/kubectl.nix
    ../../packages/netutils.nix
    ../../packages/nvim.nix
    ../../packages/starship.nix
    ../../packages/sysutils.nix
    ../../packages/tmux.nix
  ];
  vim = t.eval [ ../../packages/vim.nix ];
  golang = t.eval [
    ../../packages/golang.nix
    {
      workstation.users = [ "alice" ];
      users.users.alice.isNormalUser = true;
    }
  ];
  golangChanged = t.eval [
    ../../packages/golang.nix
    {
      workstation.users = [ "alice" ];
      users.users.alice.isNormalUser = true;
      environment.sessionVariables = {
        GOPROXY = "https://proxy.golang.org,direct";
        GOSUMDB = "sum.golang.org";
      };
    }
  ];
  rustup = t.eval [
    ../../packages/rustup.nix
    {
      workstation.users = [ "alice" ];
      users.users.alice.isNormalUser = true;
    }
  ];
  rustupChanged = t.eval [
    ../../packages/rustup.nix
    {
      workstation.users = [ "alice" ];
      users.users.alice.isNormalUser = true;
      environment.sessionVariables.RUSTC_VERSION = "nightly";
    }
  ];
  git = t.lib.foldl' t.lib.recursiveUpdate { } config.programs.git.config;
in
t.check "modules/packages" {
  evaluates = t.validSystem config;
  vim-evaluates = t.validSystem vim;
  golang-evaluates = t.validSystem golang && t.validSystem golangChanged;
  rustup-evaluates = t.validSystem rustup && t.validSystem rustupChanged;
  command-line-tools =
    config.programs.mtr.enable
    && t.hasPackages config.environment.systemPackages [
      "git"
      "gitflow"
      "gh"
      "lazygit"
      "kubectl"
      "k9s"
      "cri-tools"
      "kubernetes-helm"
      "bind"
      "curl"
      "ethtool"
      "inetutils"
      "iperf"
      "iproute2"
      "netcat-gnu"
      "nmap"
      "socat"
      "tcpdump"
      "wget"
      "btop"
      "fd"
      "file"
      "htop"
      "jq"
      "psmisc"
      "lsof"
      "pciutils"
      "ripgrep"
      "sysstat"
      "tree"
      "unzip"
      "usbutils"
      "yq"
    ];
  neovim =
    config.programs.neovim.enable
    && config.programs.neovim.defaultEditor
    && config.programs.neovim.viAlias
    && config.programs.neovim.vimAlias;
  optional-vim =
    vim.environment.variables.EDITOR == "vim" && t.hasPackages vim.environment.systemPackages [ "vim" ];
  golang-toolchain =
    t.hasPackages golang.users.users.alice.packages [
      "go"
      "gopls"
      "delve"
      "golangci-lint"
      "gotools"
    ]
    && !(t.hasPackages golang.environment.systemPackages [ "go" ])
    && golang.environment.sessionVariables.GO111MODULE == "on"
    && golang.environment.sessionVariables.GOPROXY == sources.development.goProxy
    && golang.environment.sessionVariables.GOSUMDB == sources.development.goSumdb
    && t.lib.hasInfix "$HOME/go}/bin" golang.environment.extraInit
    && golangChanged.environment.sessionVariables.GOPROXY == "https://proxy.golang.org,direct"
    && golangChanged.environment.sessionVariables.GOSUMDB == "sum.golang.org";
  rustup-toolchain =
    t.hasPackages rustup.users.users.alice.packages [
      "rustup"
      "clang-wrapper"
      "lldb"
      "cargo"
    ]
    && !(t.hasPackages rustup.environment.systemPackages [ "rustup" ])
    && rustup.environment.sessionVariables.RUSTC_VERSION == "stable"
    && rustup.environment.sessionVariables.RUSTUP_DIST_SERVER == sources.development.rustupDistServer
    && rustup.environment.sessionVariables.RUSTUP_UPDATE_ROOT == sources.development.rustupUpdateRoot
    && rustup.environment.sessionVariables.CARGO_REGISTRIES_CRATES_IO_PROTOCOL == "sparse"
    && rustup.environment.sessionVariables.CARGO_SOURCE_CRATES_IO_REPLACE_WITH == "mainland"
    &&
      rustup.environment.sessionVariables.CARGO_SOURCE_MAINLAND_REGISTRY
      == sources.development.cargoRegistry
    && rustup.environment.sessionVariables.LIBCLANG_PATH == "${t.pkgs.llvmPackages.libclang.lib}/lib"
    &&
      rustup.environment.sessionVariables.BINDGEN_EXTRA_CLANG_ARGS
      == "-isystem ${t.pkgs.llvmPackages.libclang.lib}/lib/clang/${t.lib.versions.major t.pkgs.llvmPackages.libclang.version}/include -isystem ${t.pkgs.glibc.dev}/include"
    && t.lib.hasInfix "$HOME/.cargo}/bin" rustup.environment.extraInit
    && t.lib.hasInfix "$HOME/.rustup}/toolchains/" rustup.environment.extraInit
    && rustupChanged.environment.sessionVariables.RUSTC_VERSION == "nightly";
  fish = config.programs.fish.enable;
  bat-theme = config.programs.bat.enable && config.programs.bat.settings.theme == [ "ansi" ];
  local-history =
    config.programs.atuin.enable
    && config.programs.atuin.enableFishIntegration
    && !config.programs.atuin.settings.auto_sync
    && !config.programs.atuin.settings.update_check;
  prompt = config.programs.starship.enable && config.programs.starship.interactiveOnly;
  tmux =
    config.programs.tmux.enable
    && config.programs.tmux.clock24
    && config.programs.tmux.keyMode == "vi"
    && config.programs.tmux.terminal == "tmux-256color"
    && t.lib.hasInfix "set -g mouse on" config.programs.tmux.extraConfig;
  git-editor = git.core.editor == "nvim";
  git-pull-policy = git.pull.ff == "only";
  git-conflict-review =
    git.rerere.enabled && !git.rerere.autoUpdate && git.merge.conflictStyle == "zdiff3";
  git-aliases = git.alias.s == "status --short --branch" && git.alias.ds == "diff --staged";
  git-no-plaintext-credentials = !(git ? credential);
  git-ignore-file =
    git.core.excludesFile == "/etc/gitignore"
    && t.lib.hasInfix ".env\n" config.environment.etc.gitignore.text;
}
