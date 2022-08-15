/*
  * File: configuration.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 11:17:42 pm
  * Last Modified: Monday, August 15th 2022, 10:33:03 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{
  system.stateVersion = "22.05"; # Did you read the comment?

  # WARNING! CHANGE IT BEFORE DEPLOYING IN PRODECT
  users.extraUsers.root.password = "root";

  imports = [ ./hosts/farlion ];
  #imports = [ ./hosts/chartman ];
  #imports = [ ./hosts/qemu ];
}
