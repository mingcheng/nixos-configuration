# File: firewall.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 4:14:02 pm
# Last Modified: Wednesday, August 17th 2022, 4:14:31 pm
#
# http://www.opensource.org/licenses/MIT

{
  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    ruleset = ''
      flush ruleset                                                                    
      table inet filter {
        chain input {
          type filter hook input priority 0; policy accept;
        }

        chain output {
          type filter hook output priority 0; policy accept;
        }

        chain forward {
          type filter hook forward priority 0; policy accept;
        }
      }
    '';
  };
}
