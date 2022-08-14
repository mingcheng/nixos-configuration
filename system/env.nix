{ pkgs, ... }: {
  environment.variables = {
    EDITOR = "nvim";
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };
}
