# File: i18n.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:16:03 am
# Last Modified: Thursday, August 18th 2022, 11:19:55 am
#
# http://www.opensource.org/licenses/MIT

{ lib, ... }:
{
  time.timeZone = lib.mkDefault "Asia/Shanghai";

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  console = {
    keyMap = lib.mkDefault "us";
  };
}
