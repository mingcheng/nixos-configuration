{ config, pkgs, ... }: {
  services.ntp.enable = false;
  services.timesyncd = {
    enable = true;
    servers = [ "cn.pool.ntp.org" "ntp.aliyun.com" ];
  };
}
