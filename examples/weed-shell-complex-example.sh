#!/bin/bash
## weed-shell-complex-example.sh
## Demonstrate that weed shell can be given long scripts.
bucket_name="asagi"
bucket_replication="001"
echo "#[${0##*/}]" "Starting "at $(date -u +%Y-%m-%d_%H:%M:%s_%z)"
echo "#[${0##*/}]" "Creating bucket ${bucket_name} with replication ${bucket_replication}"
echo "#[${0##*/}]" "And fixing replication"
(   tee "dbg.weed-shell.heredoc" \
    | grep -v -e '^#' -e '^$' \
    | tee "dbg.weed-shell.stdin" | tee /dev/tty \
    | weed shell \
    -master="localhost:9333" \
    -filer="localhost:8888" \
    | tee "dbg.weed-shell.stdout"
) <<EOF-weedshell
## This way you can have comments
#
## help command:
help lock
## -help argument:
lock -help
#
## Variables work too:
s3.bucket.create -name=${bucket_name} -replication ${bucket_replication}
#
#
## Ensure volumes are replicated properly
volume.list
lock
volume.check.disk
volume.fix.replication
unlock
volume.list
## Exit weed shell
exit
EOF-weedshell
echo "#[${0##*/}]" "Finished "at $(date -u +%Y-%m-%d_%H:%M:%s_%z)"
