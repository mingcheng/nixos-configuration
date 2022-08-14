{ config, lib, ... }: {
  powerManagement = {
    enable = true;

    # This will save you money and possibly your life!
    # cpuFreqGovernor = lib.mkDefault "powersave";
    cpuFreqGovernor = lib.mkDefault "performance";
  };
}
