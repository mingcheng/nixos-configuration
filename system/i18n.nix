# File: i18n.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:16:03 am
# Last Modified: Thursday, August 18th 2022, 11:19:55 am
#
# http://www.opensource.org/licenses/MIT

{
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  console = { keyMap = "us"; };
}
