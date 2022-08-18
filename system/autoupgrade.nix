# File: autoupgrade.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Tuesday, August 16th 2022, 9:10:16 pm
# Last Modified: Tuesday, August 16th 2022, 9:35:49 pm
#
# http://www.opensource.org/licenses/MIT

{
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    # stateVersion = "22.05";
    channel = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-22.05";
  };
}
