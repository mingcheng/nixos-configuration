{
  services.udev = {
    extraRules = ''
      SUBSYSTEM == "net", ACTION=="add", DRIVERS=="virtio_net", NAME="eth0"
    '';
  };
}
