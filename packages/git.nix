#!#
# Copyright (c) 2026 mingcheng
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: git.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: Sunday, August 14th 2022, 9:45:39 pm
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-04 12:18:24
##

{ pkgs, ... }: {
  programs.git = {
    enable = true;

    config = {
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
      pull = {
        ff = "only";
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
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

      # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/javascript.section.md#git-protocol-error
      url = {
        "https://github.com/" = {
          insteadOf = "git://github.com/";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [ gitflow ];
}
