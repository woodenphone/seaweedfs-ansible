#!/bin/bash
## weed_volume_list_human.sh
## By: Ctrl-S, 2021-06-18 - 2021-09-29.
##
echo -e "volume.list\nexit\n" | weed shell 2>&1 | python3 weed_volume_list_human_many_vals.py ;
date