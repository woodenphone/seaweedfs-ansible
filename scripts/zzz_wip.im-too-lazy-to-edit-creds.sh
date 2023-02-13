#!/bin/bash
## im-too-lazy-to-edit-creds.sh
## Randomly generate credentials for lazy users.
## USAGE: $ bash im-too-lazy-to-edit-creds.sh "vars.default.yml
##
## Example target line: s3json_admin_access_key: 'FIXME_DEFAULT_VALUE.s3json_admin_access_key'
##
## AUTHOR: Ctrl-S
## CREATED: 2021-05-15
## MODIFIED: 2021-05-15

p="## [${0##*/}]" ## Message prefix.
echo $p "Replacing credential placeholders with random values..."

## Get target from CLI params
conf_file="${1?}"
echo $p "conf_file=${conf_file}"


## Replace each value with a different random string:
for i in {1..20..1} ## {START..END[..INCREMENT]}
do
  echo $p "Iteration: $i"

  ## Generate a random string, 16 hexadecimal chars.
  random_val="$( < /dev/urandom tr -dc a-f0-9 | head -c${1:-16};)"
  pat="1 s/FIXME_DEFAULT_VALUE[a-zA-Z0-9-_]+/${random_val?}/"
  echo $p "find_pat=$find_pat"
  ## Only replace first match: $ sed '1 s/foo/bar/'
  sed -r --in-place=".bkup" --expression="$find_pat" "${conf_file?}"
  ## ^ Multiline-split for puny terminals. ^
done

#echo "\ns3json_admin_access_key: 'FIXME_DEFAULT_VALUE.s3json_admin_access_key'\n" | sed --regexp-extended --expression="1 s/FIXME_DEFAULT_VALUE[a-zA-Z0-9-_]+/$( < /dev/urandom tr -dc a-f0-9 | head -c${1:-16};)/"

echo $p "End of script."
## 
## https://www.man7.org/linux/man-pages/man1/sed.1.html
## https://linuxhint.com/50_sed_command_examples/
##