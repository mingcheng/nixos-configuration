# Copyright (c) 2026 mingcheng <mingcheng@apache.org>
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: qemu-headless.nix
# Author: mingcheng <mingcheng@apache.org>
# File Created: 2026-11-14 15:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-14

# Headless gateway image: every GUI component is explicitly removed and disabled.
# Keep the VM host's existing hard boundaries in this shared module.
{ lib, ... }:
{
  services = {
    # Display servers, display managers, the shared desktop session bundle,
    # GUI input drivers and the KMS graphical console.
    xserver.enable = lib.mkForce false;
    displayManager.enable = lib.mkForce false;
    flatpak.enable = lib.mkForce false;
    graphical-desktop.enable = false;
    libinput.enable = false;
    kmscon.enable = false;
    openssh.settings.X11Forwarding = false;
  };

  programs = {
    xwayland.enable = lib.mkForce false;
    dconf.enable = false;
    ssh.setXAuthLocation = false;
  };

  # GPU userspace (Mesa, OpenGL, Vulkan) and the graphical boot splash.
  hardware.graphics.enable = false;
  boot.plymouth.enable = false;

  # Fonts, toolkit theming and freedesktop.org desktop integration.
  fonts = {
    enableDefaultPackages = false;
    fontconfig.enable = false;
    fontDir.enable = false;
  };
  qt.enable = false;
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    portal.enable = lib.mkForce false;
    sounds.enable = false;
    terminal-exec.enable = false;
  };

  # The interactive VM opens no display window and attaches no virtual keyboard.
  virtualisation.vmVariant.virtualisation = {
    graphics = false;
    qemu.virtioKeyboard = false;
  };
}
