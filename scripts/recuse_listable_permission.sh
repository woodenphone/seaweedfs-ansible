#!/bin/bash
## recuse_listable_permission.sh
## Set every dir in the current path as listable
## Takes the full dirpath to the seaweedfs volume as the argument. (-dir=)
## Author: Ctrl-S
echo "##[${0##*/}]" "Starting" "(at date=$(date) epoch=$(date +%s))" >&2
echo "##[${0##*/}]" "initial" "PWD=$PWD" >&2
echo "##[${0##*/}]" "argv @=$@" >&2

# Use given path if one is passed as the argument.
if [[ -z ${1} ]]; then
  cd "${1}" >&2
  echo "##[${0##*/}]" "move to arg" "PWD=$PWD" >&2
fi

## Abort if pointed at $HOME, common error case.
if [[ $PWD = $HOME ]]; then
  echo "##[${0##*/}]" "Initial dir was HOME, aborting." >&2
  exit 1
fi


## Set dir listable by all until we reach the root dir
while [ "$PWD" != "/" ]; do
  echo "##[${0##*/}]" "chmod loop" "PWD=$PWD" >&2
  chmod -v a+X $PWD  >&2 ## chmod '+X' means set listable for dirs.
  cd ..
done

echo "##[${0##*/}]" "Finished" "(at date=$(date) epoch=$(date +%s))" >&2
exit 0