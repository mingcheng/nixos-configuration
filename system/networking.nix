# File: networking.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:09:16 am
# Last Modified: Thursday, August 18th 2022, 11:14:57 am
#
# http://www.opensource.org/licenses/MIT

{
  networking = {
    enableIPv6 = false;
    useDHCP = true;
  };
}
