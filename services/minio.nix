# File: minio.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Wednesday, August 17th 2022, 4:31:05 pm
# Last Modified: Wednesday, August 17th 2022, 4:31:13 pm
#
# http://www.opensource.org/licenses/MIT

{ lib, ... }: {
  services.minio = {
    enable = true;
    # listenAddress = ":9000";
    # consoleAddress = ":9001";
    # configDir = "";
    # dataDir = ""
  };
}
