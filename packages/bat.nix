/*
  * File: bat.nix
  * Author: Ming Cheng<mingcheng@outlook.com>
  * 
  * Created Date: Sunday, August 14th 2022, 9:45:39 pm
  * Last Modified: Monday, August 15th 2022, 10:31:41 pm
  * 
  * http://www.opensource.org/licenses/MIT
*/

{
  programs.bat = {
    config = { theme = "ansi-dark"; };
    enable = true;
  };
}
