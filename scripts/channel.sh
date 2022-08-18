###
# File: channel.sh
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Tuesday, August 16th 2022, 12:38:55 am
# Last Modified: Thursday, August 18th 2022, 2:43:55 pm
#
# http://www.opensource.org/licenses/MIT
###

nix-channel --add https://mirror.nju.edu.cn/nix-channels/nixos-22.05 nixos
nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-22.05 tsinghua
nix-channel --add https://mirror.nju.edu.cn/nix-channels/nixos-22.05 nju