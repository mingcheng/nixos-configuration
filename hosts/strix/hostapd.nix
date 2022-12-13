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
      bridge=br0
      wpa=3
      wpa_key_mgmt=WPA-PSK
      wpa_pairwise=TKIP
      rsn_pairwise=CCMP
      macaddr_acl=0
      auth_algs=1
      ignore_broadcast_ssid=0
      wmm_enabled=0
      country_code=CN
    '';
  };
}
