#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: git.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 9:45:39 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-05 19:14:24
##

{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    config = {
      user = {
        name = "mingcheng";
        email = "mingcheng@apache.org";
      };
      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "trailing-space,cr-at-eol";
        excludesFile = "/etc/gitignore";
      };

      alias = {
        c = "commit";
        p = "push";
        st = "status";
        s = "status --short --branch";
        co = "checkout";
        sw = "switch";
        br = "branch";
        d = "diff";
        ds = "diff --staged";
        lg = "log --graph --decorate --oneline";
        last = "log -1 --stat";
      };

      color.ui = "auto";
      commit.verbose = true;
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      status.showStash = true;
      fetch.prune = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      pull.ff = "only";
      init.defaultBranch = "main";
      rebase = {
        autoStash = true;
        autoSquash = true;
      };
      merge.conflictStyle = "zdiff3";
      rerere = {
        enabled = true;
        # Reused conflict resolutions still need review before staging.
        autoUpdate = false;
      };

      # Credential helper configuration set to store credentials in plaintext (uncomment to enable)
      # credential.helper = "store";
      # url = {
      #   "git@github.com:".insteadOf = "gh:";
      #   "https://github.com/".insteadOf = "git://github.com/";
      # };
    };
  };

  environment.etc."gitignore".text = ''
    *.swp
    *.swo
    *~
    .idea/
    .vscode/
    *.sublime-*

    .DS_Store
    Thumbs.db

    *.log
    *.tmp
    *.temp
    node_modules/
    __pycache__/
    *.pyc
    .env
    .env.local

    dist/
    build/
    *.o
    *.a
    *.so
  '';

  environment.systemPackages = with pkgs; [
    gitflow
    gh
    lazygit
  ];
}
