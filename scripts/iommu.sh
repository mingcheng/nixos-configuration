#!/usr/bin/env bash
#
# Copyright (c) 1970-2026 mingcheng, all rights reserved.
#
# This source code is licensed under the MIT License,
# which is located in the LICENSE file in the source tree's root directory.
#
# File: iommu.sh
# Author: mingcheng <mingcheng@apache.org>
# File Created: 1970-01-01 08:00:00
#
# Modified By: mingcheng <mingcheng@apache.org>
# Last Modified: 2026-11-06 15:33:32
##


set -euo pipefail

shopt -s nullglob
for group in /sys/kernel/iommu_groups/*; do
  printf 'IOMMU Group %s:\n' "${group##*/}"
  for device in "$group"/devices/*; do
    printf '\t'
    lspci -nns "${device##*/}"
  done
done
