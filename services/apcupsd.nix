{ config, pkgs, ... }: {
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSCABLE ether
      UPSTYPE net
      DEVICE 192.168.0.6:3551
    '';
  };
}
