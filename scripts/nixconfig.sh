###
# File: nixconfig.sh
# Author: Ming Cheng<mingcheng@outlook.com>
# 
# Created Date: Thursday, August 18th 2022, 2:38:16 pm
# Last Modified: Thursday, August 18th 2022, 2:40:02 pm
# 
# http://www.opensource.org/licenses/MIT
###

mkdir -p ~/.config/nix
echo "substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" > ~/.config/nix/nix.conf
source ./channel.sh

nix-channel --list
nix-channel --update