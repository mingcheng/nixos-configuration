#!#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: rustup.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-16 11:48:33
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-16 12:34:08
##

{ lib, pkgs, ... }:
let
  defaultChannel = "stable";
  libclang = pkgs.llvmPackages.libclang.lib;
  clangVersion = lib.versions.major pkgs.llvmPackages.libclang.version;
  rustcTarget = pkgs.stdenv.hostPlatform.rust.rustcTarget;
in
{
  imports = [
    ./user-packages.nix
  ];

  # Place after develop.nix's mkBefore (500) so gnumake remains first,
  # while still preceding workstation.nix (600) and GUI packages (1000).
  # rustup precedes cargo so its cargo/rustc proxies win profile collisions;
  # pkgs.cargo then only contributes man pages and shell completions.
  workstation.userPackages =
    with pkgs;
    lib.mkOrder 550 [
      rustup
      clang
      lldb
      cargo
    ];

  # Rustup and crates.io mirrors come from system/mainland.nix.
  # https://rust-lang.github.io/rust-bindgen/requirements.html#nixos
  environment.sessionVariables = {
    RUSTC_VERSION = lib.mkDefault defaultChannel;
    LIBCLANG_PATH = lib.mkDefault "${libclang}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = lib.mkDefault (
      "-isystem ${libclang}/lib/clang/${clangVersion}/include " + "-isystem ${pkgs.glibc.dev}/include"
    );
  };

  environment.extraInit = ''
    export PATH="''${CARGO_HOME:-$HOME/.cargo}/bin:$PATH:''${RUSTUP_HOME:-$HOME/.rustup}/toolchains/''${RUSTC_VERSION:-${defaultChannel}}-${rustcTarget}/bin"
  '';
}
