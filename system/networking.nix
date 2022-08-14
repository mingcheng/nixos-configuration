{ config, ... }: {
  networking = {
    hostName = "chartman";
    enableIPv6 = false;
    useDHCP = true;
  };
}
