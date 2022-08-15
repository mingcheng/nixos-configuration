{ config, ... }: {
  networking = {
    enableIPv6 = false;
    useDHCP = true;
  };
}
