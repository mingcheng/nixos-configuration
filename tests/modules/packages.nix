let
  t = import ../lib.nix;
  config = t.eval [
    ../../packages/atuin.nix
    ../../packages/bat.nix
    ../../packages/fish.nix
    ../../packages/git.nix
    ../../packages/golang.nix
    ../../packages/kubectl.nix
    ../../packages/netutils.nix
    ../../packages/nvim.nix
    ../../packages/starship.nix
    ../../packages/tmux.nix
  ];
  vim = t.eval [ ../../packages/vim.nix ];
  git = t.lib.foldl' t.lib.recursiveUpdate { } config.programs.git.config;
in
t.check "modules/packages" {
  evaluates = t.validSystem config;
  vim-evaluates = t.validSystem vim;
  command-line-tools = t.hasPackages config.environment.systemPackages [
    "git"
    "gitflow"
    "gh"
    "lazygit"
    "gnumake"
    "go"
    "kubectl"
    "k9s"
    "cri-tools"
    "kubernetes-helm"
    "inetutils"
    "netcat-gnu"
  ];
  neovim =
    config.programs.neovim.enable
    && config.programs.neovim.defaultEditor
    && config.programs.neovim.viAlias
    && config.programs.neovim.vimAlias;
  optional-vim =
    vim.environment.variables.EDITOR == "vim" && t.hasPackages vim.environment.systemPackages [ "vim" ];
  fish = config.programs.fish.enable;
  bat-theme = config.programs.bat.enable && config.programs.bat.settings.theme == [ "ansi" ];
  local-history =
    config.programs.atuin.enable
    && config.programs.atuin.enableFishIntegration
    && !config.programs.atuin.settings.auto_sync
    && !config.programs.atuin.settings.update_check;
  prompt = config.programs.starship.enable && config.programs.starship.interactiveOnly;
  tmux-opt-in = !config.programs.tmux.enable && config.programs.tmux.keyMode == "vi";
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
