# File: sudo.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:09:16 am
# Last Modified: Thursday, August 18th 2022, 11:15:14 am
#
# http://www.opensource.org/licenses/MIT

{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };
}
