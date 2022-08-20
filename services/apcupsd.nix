# File: apcupsd.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 9:45:39 pm
# Last Modified: Monday, August 15th 2022, 10:41:19 pm
#
# http://www.opensource.org/licenses/MIT

{
  services.apcupsd = {
    enable = true;
    configText = ''
        UPSCABLE usb
        UPSTYPE usb
        DEVICE 

      	ONBATTERYDELAY 6
      	BATTERYLEVEL 5
      	MINUTES 3
      	NOLOGON always

        NETSERVER on
        NISIP 0.0.0.0
        NISPORT 3551

        UPSCLASS standalone
        UPSMODE share

        SELFTEST 168
    '';
  };
}
