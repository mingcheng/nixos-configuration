###
# File: Makefile
# Author: Ming Cheng<mingcheng@outlook.com>
# 
# Created Date: Wednesday, August 17th 2022, 10:14:18 am
# Last Modified: Wednesday, August 17th 2022, 10:14:58 am
# 
# http://www.opensource.org/licenses/MIT
###


fmt:
	@nix-shell -p nixfmt-classic --run "find . -iname '*.nix' -exec nixfmt {} \;"
