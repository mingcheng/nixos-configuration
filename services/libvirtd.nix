{ config, pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      ovmf.enable = true;
      swtpm.enable = true;
    };
    onShutdown = "shutdown";
    allowedBridges = [ "br0" "virbr0" ];
  };
}
