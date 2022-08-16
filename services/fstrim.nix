/*
  * File: fstrim.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 9:45:39 pm
  * Last Modified: Monday, August 15th 2022, 10:36:58 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{ lib, ... }:
{
  services.fstrim.enable = lib.mkDefault true;
}
