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
# Last Modified: 2026-11-16 11:55:00
##

{ lib, pkgs, ... }:
let
  defaultChannel = "stable";
  mirrors = (import ../sources.nix).development;
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
  workstation.userPackages =
    with pkgs;
    lib.mkOrder 550 [
      rustup
      clang
      lldb
      cargo-binstall
    ];

  # https://rust-lang.github.io/rust-bindgen/requirements.html#nixos
  environment.sessionVariables = {
    RUSTC_VERSION = lib.mkDefault defaultChannel;
    RUSTUP_DIST_SERVER = lib.mkDefault mirrors.rustupDistServer;
    RUSTUP_UPDATE_ROOT = lib.mkDefault mirrors.rustupUpdateRoot;
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL = lib.mkDefault "sparse";
    CARGO_SOURCE_CRATES_IO_REPLACE_WITH = lib.mkDefault "mainland";
    CARGO_SOURCE_MAINLAND_REGISTRY = lib.mkDefault mirrors.cargoRegistry;
    LIBCLANG_PATH = lib.mkDefault "${libclang}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = lib.mkDefault (
      "-isystem ${libclang}/lib/clang/${clangVersion}/include " + "-isystem ${pkgs.glibc.dev}/include"
    );
  };

  environment.extraInit = ''
    export PATH="''${CARGO_HOME:-$HOME/.cargo}/bin:$PATH:''${RUSTUP_HOME:-$HOME/.rustup}/toolchains/''${RUSTC_VERSION:-${defaultChannel}}-${rustcTarget}/bin"
  '';
}
