# File: resolved.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Friday, August 19th 2022, 10:24:36 am
# Last Modified: Friday, August 19th 2022, 10:24:40 am
#
# http://www.opensource.org/licenses/MIT

{
  services.resolved = {
    enable = true;
    dnssec = "false";
  };
}
