#!/bin/bash
## mk-certstrap-help-msgs.sh
## Dump certstrap help text to files for easier reading.
## USAGE: $ bash mk-certstrap-help-msgs.sh '/usr/bin/weed' '/var/lib/seaweedfs/help-certstrap'
## Author: Ctrl-S
## Created: 2021-05-14
## Updated: 2021-05-14

## Take CLI args for variables
cs_bin="${1}" # Certstrap executable path.
help_dir="${2}" # Dir to put docs in.
p="# [${0##*/}]" # Message prefix.

echo $p "args=$@"
echo $p "Using: cs_bin=${cs_bin}"
echo $p "Using: help_dir=${help_dir}"
echo $p "Version of certstrap:"
$cs_bin -v

# Record version docs apply to:
$cs_bin -v > "${help_dir?}/installed_version.txt" 2>&1

echo $p "Populate a folder with the certstrap help messages"
mkdir -vp "${help_dir?}"
## Plain weed --help text:
$cs_bin --help  > "${help_dir}/certstrap.txt" 2>&1
## Subcommand --help text:
$cs_bin init --help  > "${help_dir}/init.txt" 2>&1
$cs_bin request-cert --help  > "${help_dir}/request-cert.txt" 2>&1
$cs_bin sign --help  > "${help_dir}/sign.txt" 2>&1
$cs_bin revoke --help  > "${help_dir}/revoke.txt" 2>&1

