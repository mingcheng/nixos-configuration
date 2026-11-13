# File: timesyncd.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 9:45:39 pm
# Last Modified: Monday, August 15th 2022, 10:37:40 pm
#
# http://www.opensource.org/licenses/MIT

{ lib, ... }:
{
  services.ntp.enable = lib.mkDefault false;
  services.timesyncd = {
    enable = lib.mkDefault true;
    servers = lib.mkDefault [
      "cn.pool.ntp.org"
      "ntp.aliyun.com"
    ];
  };
}
