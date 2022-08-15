/*
  * File: kubectl.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 10:25:50 pm
  * Last Modified: Monday, August 15th 2022, 11:48:00 am
  * 
  * http://www.opensource.org/licenses/MIT
*/

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    cri-tools
    kubernetes-helm
  ];
}
