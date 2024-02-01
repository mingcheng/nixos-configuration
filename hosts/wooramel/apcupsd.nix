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
      UPSCABLE ether
      UPSTYPE net
      DEVICE 192.168.0.2:3551
    '';
  };
}
