# File: ld.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, September 1st 2022, 6:52:53 pm
# Last Modified: Thursday, September 1st 2022, 7:28:35 pm
#
# http://www.opensource.org/licenses/MIT

{ lib, pkgs, ... }:
with pkgs;
let
  libraryPath = lib.makeLibraryPath [ stdenv.cc.cc zlib openssl glib dbus ];
  nixLd = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
in {
  programs.nix-ld.enable = true;
  environment.variables = {
    NIX_LD_LIBRARY_PATH = libraryPath;
    NIX_LD = nixLd;
  };
}
