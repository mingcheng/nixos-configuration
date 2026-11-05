# File: prometheus.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Tuesday, August 16th 2022, 4:53:35 pm
# Last Modified: Tuesday, August 16th 2022, 4:55:52 pm
#
# http://www.opensource.org/licenses/MIT

{
  services.prometheus = {
    exporters.node.enable = true;
  };
}
