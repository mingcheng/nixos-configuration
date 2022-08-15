/*
  * File: usb.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Monday, August 15th 2022, 2:33:25 pm
  * Last Modified: Monday, August 15th 2022, 2:33:26 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{
  imports = [
    ../qemu
    ../../packages/default.nix
    ../../packages/kubectl.nix
    ../../packages/git.nix
    ../../packages/nvim.nix
    ../../packages/netutils.nix
  ];

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.kernel = {
    sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
    };
  };

  boot.kernelParams = [
    "verbose"
  ];

  boot.kernelModules = [
    "btrfs"
    "f2fs"
  ];

  # fileSystems."/nix" = {
  #   device = "/dev/disk/by-label/nix";
  #   fsType = "btrfs";
  #   neededForBoot = true;
  #   options = [ "defaults" "subvol=@nix" ];
  # };

  # fileSystems."/home" = {
  #   device = "/dev/disk/by-label/nix";
  #   fsType = "btrfs";
  #   neededForBoot = true;
  #   options = [ "defaults" "subvol=@home" ];
  # };

  # boot.growPartition = true;
  # boot.loader.grub.device = "/dev/vda";
  # boot.loader.timeout = 0;

  users.extraUsers.root.password = lib.mkForce "root";
}
