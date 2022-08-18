# File: network_hosts.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:09:16 am
# Last Modified: Thursday, August 18th 2022, 11:14:48 am
#
# http://www.opensource.org/licenses/MIT

{ ... }:

{
  networking.extraHosts = ''
    140.82.113.26                 alive.github.com
  '';
}
