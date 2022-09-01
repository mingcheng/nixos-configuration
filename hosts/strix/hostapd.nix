# File: hostapd.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Monday, August 29th 2022, 7:58:56 pm
# Last Modified: Monday, August 29th 2022, 8:00:09 pm
#
# http://www.opensource.org/licenses/MIT

{
  services.udev = {
    extraRules = ''
      SUBSYSTEM == "net", ACTION=="add", DRIVERS=="rtw_8822be", NAME="wlan0"
    '';
  };

  services.hostapd = {
    enable = true;

    interface = "wlan0";
    hwMode = "g";
    ssid = "ChinaNet-fmE4";
    wpaPassphrase = "5Hgix6FxTwB60P";
    extraConfig = ''
      bridge=br0
    '';
  };
}
