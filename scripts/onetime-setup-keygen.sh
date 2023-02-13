#!/bin/bash
## onetime-setup-keygen.sh
echo "#[${0##*/}]" "== Starting =="

## CA
ca_common_name='SeaweedFS_CA'
ca_passphrase='this example passphrase is shit'
ca_expiry='5 years'

## Certs
certs_passphrase='you ought to fucking change this'
cert_expiry='5 years'
## == == == == == == == == == ==
echo "#[${0##*/}]" "Make CA cert: $ca_common_name"
certstrap init \
  --expires="$ca_expiry" \
  --passphrase="$ca_passphrase" \
  --common-name="$ca_common_name"


## == == == == == == == == == ==
echo "#[${0##*/}]" "Make client certs"


cert_names=(
  'master'
  'filer'
  'volume'
  'client'
)

for cert_name in ${cert_names[@]}
do
  echo "#[${0##*/}]" "cert_name=${cert_name}"
  echo "#[${0##*/}]" "Create: ${cert_name}"
  certstrap request-cert \
    --passphrase="$certs_passphrase" \
    --common-name="${cert_name}"

  echo "#[${0##*/}]" "Sign: ${cert_name}"
  certstrap sign \
    --CA="$ca_common_name" \
    --passphrase="$ca_passphrase" \
    --expires="$cert_expiry" \
    "${cert_name}"
done


echo "#[${0##*/}]" "== Finished =="