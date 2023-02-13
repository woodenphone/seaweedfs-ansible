#!/bin/bash
## .bash_aliases_seaweedfs
## bash_aliases_seaweedfs.sh
## Define handy shell aliases for seaweedfs.
## USAGE: [in .bashrc]: source '.bash_aliases_seaweedfs.sh'
## Author: Ctrl-S
## [Fedora]
alias s3weed='s3cmd "--config=$HOME/.s3cfg-weed" "--host=localhost:8333" --human-readable-sizes'
alias weed-vol-ls='/var/lib/seaweedfs/scripts/weed-vol-ls'
