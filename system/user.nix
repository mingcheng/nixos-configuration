# File: user.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Sunday, August 14th 2022, 11:17:23 pm
# Last Modified: Monday, August 15th 2022, 10:43:44 pm
#
# http://www.opensource.org/licenses/MIT

{ pkgs, ... }: {
  users = {
    users.mingcheng = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "libvirtd" "docker" "network" "davfs2" ];
      shell = pkgs.bash;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzyxBQMp6zOhVh87RKiCwuKTqkreoZWgp78zcQV2Rv3 mingcheng@apache.org"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjIcJTUCPanNJIeaiyF3rrWlpFIf3QOwufqAf0Kp84deZn5uy2AxWEmSI3iOwTc7WFwXosdSmILLHWNjKgkMeUJ093YMIHnBJ3mMjKpAEA6WIBdRdT/FnK+Jt/KtohqObHjXKF0op8/3dM/g80GWb4G26a0S3nRY384ON0Wu+2Lcynos6MLsQxgqNwvsVp8r7JEM07rKSZe0HCA1IMAy4KPrAnfkgcibi+F1NMCJoe7mLYs3CoLgBMKriLuPxIcYxx0FWLxU1ElZklt8hP31CX4evk9snVFcaYTMp6FFF3in3ccnQT+ddprZ9pbkFPlpu0i/araSMA1wquYCSPfcYh mingcheng@taobao.com"
      ];
    };
  };
}
