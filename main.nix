/*
  * File: configuration.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 11:17:42 pm
  * Last Modified: Monday, August 15th 2022, 10:33:03 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

let
  host = builtins.getEnv "NIX_BUILD_HOST";
in
{
  # WARNING! CHANGE IT BEFORE DEPLOYING IN PRODECT
  users.extraUsers.root.password = "root";

  # write build variable to envirment
  environment.variables = {
    NIX_BUILD_HOST = "${host}";
  };

  # imports the main nix file from each directory
  imports = [ ./hosts/${host} ];
}
