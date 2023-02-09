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
      SUBSYSTEM == "net", ACTION=="add", DRIVERS=="iwlwifi", NAME="wlan0"
    '';
  };

  services.hostapd = {
    enable = true;

    interface = "wlan0";
    hwMode = "g";
    ssid = "ChinaNet-fmE4";
    wpaPassphrase = "5Hgix6FxTwB60P";
    extraConfig = ''
      auth_algs=1
      bridge=br0
      channel=7
      country_code=CN
      ieee80211d=1
      ieee80211n=1
      ignore_broadcast_ssid=0
      logger_stdout=1
      logger_stdout_level=2
      macaddr_acl=0
      rsn_pairwise=CCMP
      wmm_enabled=1
      wpa=2
      wpa_key_mgmt=WPA-PSK
      wpa_pairwise=TKIP
    '';
  };
}
