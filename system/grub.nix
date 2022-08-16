/*
  * File: grub.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Tuesday, August 16th 2022, 12:36:27 am
  * Last Modified: Tuesday, August 16th 2022, 12:36:30 am
  * 
  * http://www.opensource.org/licenses/MIT
*/

{
  boot.loader.grub.forceInstall = false; # RISKY!
  boot.loader.grub.enable = true;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.extraEntries = ''
    menuentry "Reboot" {
      reboot
    }
    menuentry "Poweroff" {
      halt
    }
  '';

  boot.loader.efi = {
    efiSysMountPoint = "/efi";
  };
}
