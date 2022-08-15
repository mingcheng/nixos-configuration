/*
  * File: libvirtd.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 9:45:39 pm
  * Last Modified: Monday, August 15th 2022, 10:37:10 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      ovmf.enable = true;
      swtpm.enable = true;
    };
    onShutdown = "shutdown";
    allowedBridges = [ "br0" "virbr0" ];
  };
}
