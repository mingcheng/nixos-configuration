/*
  * File: netutils.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 10:37:28 pm
  * Last Modified: Monday, August 15th 2022, 10:31:12 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ bind inetutils netcat-gnu ];
}
