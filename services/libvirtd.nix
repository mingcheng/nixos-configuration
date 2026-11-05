# File: libvirtd.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 9:45:39 pm
# Last Modified: Monday, August 15th 2022, 10:37:10 pm
#
# http://www.opensource.org/licenses/MIT

{
  environment.variables = {
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };

  security.polkit.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
    };
    onShutdown = "shutdown";
    allowedBridges = [
      "br0"
      "virbr0"
    ];
  };
}
