# File: shell_alias.nix
# Author: Ming Cheng<mingcheng@outlook.com>
#
# Created Date: Thursday, August 18th 2022, 11:09:16 am
# Last Modified: Thursday, August 18th 2022, 11:15:10 am
#
# http://www.opensource.org/licenses/MIT

{
  environment.shellAliases = {
    cp = "cp -i";
    df = "df -h";
    du = "du -sh";
    ll = "ls -l";
    lm = "ls -m";
    ls = "ls --color -F -h";
    mv = "mv -i";
    rm = "rm -i";
  };
}
