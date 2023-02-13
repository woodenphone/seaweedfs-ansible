# README for seaweedfs ansible example


## FOREWORD - Purpose of this repository
This is a collection of ansible code to setup seaweedfs which is nearly-functional.
Various machine-specific values such as usernames, disk IDs, mountpoints, and so on have been left with placeholders which will need to be replaced with appropriate values for your particular system.
You will likely need to fill in, copy-paste, comment out, and remove various blocks of YAML; since each machine has its own disk drives and usernames.
It is expected that you as a system administrator will skim through to get a basic understanding of the actions performed.

The appropriate places to start skimming through are:
- the main playbook `main.pb.yml` 
- the main variables/config declaration `vars/vars.yml`

Most of the code assumes you are using Fedora-like Linux, but some Debian-like equivalents are present, though likely not enough on their own for use on Debian-like Linux without some extra work to insert Debian-style alternative actions throughout the playbooks. Distribution-specific actions tend to have conditionals associated with them to restrict them to the appropriate distribution family.

In short, this is provided more as a starting point than a works-out-of-the-box solution. 
It's 95% of the way ready and you need to slap together the 5% specific to your machine with what's here.


## Prerequisites
Things that need doing first.

System packages on controller:
```
$ sudo dnf install ansible python3
```

Ansible packages on controller:
```
$ ansible-galaxy collection install community.general
$ ansible-galaxy collection install community.posix
$ ansible-galaxy collection install community.postgresql
$ ansible-galaxy install git+https://github.com/DevoInc/ansible-role-systemd-service.git
$ ansible-galaxy install 0x0i.systemd
```


## Usage
How to run the playbooks.

* When running remotely: `-i .hosts.yml`
* When controller is the target: `-i localhost.yml`

For a fresh install, run the following stages in numerical order.


### (NaN) condensed (Lazymode)
For lazy copypasta use.
```
#!/bin/bash
## lazy-deploy-everything.sh
cd ~/seaweedfs
git pull
sudo whoami # Cache sudo auth.
ansible-playbook -vv manual-mounts.pb.yml
ansible-playbook -vv main.pb.yml
ansible-playbook -vv manual-pgsql.pb.yml
```
* This is mainly for my own sanity.


### Install certstrap and seaweedfs binaries for setup
Need certstrap to create certificates (If using certificates)
```
$ ansible-playbook -vv manual-binaries.pb.yml
```

### (1) Special task - disks/mounts
Setting up disks is infrequently done and kind of risky, so it's a seperate step.

Setup disks (on target):
```
$ ansible-playbook -vv manual-mounts.pb.yml
```

* Does not depend on other plays.

* ! Be careful when fucking with filesystems and such !


### (2) Regular tasks
This is most setup other than the special tasks listed above.

Deploy (on target):
```
$ ansible-playbook -vv main.pb.yml
```

* Requires mounts so that dirs can be setup.


### (3) Special task - postgresql
Setting up database stuff is infrequently done, so it's a seperate step.

Setup postgresql (on target):
```
$ ansible-playbook -vv manual-pgsql.pb.yml
```

* Requires weed user setup, weed dirs



## Configuration
Configuring seaweedfs.

You'll need to do at least some of this.


### Seaweedfs security

#### Certificates
* See: https://github.com/chrislusf/seaweedfs/wiki/Security-Configuration

Check if you've already made keys:
```
ls -lah files/certs/
```

Keygen output will go into out/
If keys not generated already, run script to generate them:
```
$pwd
.../REPODIR/
$ chmod +x scripts/onetime-setup-keygen.sh
$ ./scripts/onetime-setup-keygen.sh
$ mkdir -vp files/certs/
$ mv out/* files/certs*
```

* Certstrap seems to dislike being given a name ending in a numeral.


#### Security config toml
Create security.toml template via weed scaffold:
```
$ weed scaffold -config=security 2> security.toml
```

To generate a 32 character hexadecimal string:
```
$ < /dev/urandom tr -dc a-f0-9 | head -c${1:-32};echo;
```

Example `/etc/seaweedfs/security.toml`:
```
## /etc/seaweedfs/security.toml
# Put this file to one of the location, with descending priority
#    ./security.toml
#    $HOME/.seaweedfs/security.toml
#    /etc/seaweedfs/security.toml

[jwt.signing]
key = "blahblahblahblah"

# all grpc tls authentications are mutual
[grpc]
ca = "/etc/seaweedfs/SeaweedFS_CA.crt"

[grpc.volume]
cert = "/etc/seaweedfs/volume.crt"
key  = "/etc/seaweedfs/volume.key"

[grpc.master]
cert = "/etc/seaweedfs/master.crt"
key  = "/etc/seaweedfs/master.key"

[grpc.filer]
cert = "/etc/seaweedfs/filer.crt"
key  = "/etc/seaweedfs/filer.key"

[grpc.client]
cert = "/etc/seaweedfs/client.crt"
key  = "/etc/seaweedfs/client.key"
```


#### Seaweedfs S3 API config
* Seaweedfs S3-host credentials and access are defined inside: `files/s3_conf.json`

* JSON has strict syntax.

* Only applied when the `weed s3` process starts.


### Firewall configuration
Fedora uses firewalld.
Example task located at `tasks/firewalld.yml`


### nginx proxy-pass configuration
TODO: Writeme
* Used to serve files to outside world while restricting requests.
* Allows seaweedfs to never have to see the outside internet.


## Debugging - Ansible
* Use inventory file: `-i .hosts.yml`

Generic invokation template:
```
$ ansible-playbook -vv -i .hosts.yml PLAYBOOK.pb.yml
```

Full syntax-check:
```
$ ansible-playbook -vv --syntax-check -i .hosts.yml main.pb.yml
```

Full check:
```
$ ansible-playbook -vv --check -i .hosts.yml main.pb.yml
```

Run testing shim playbook:
```
$ ansible-playbook -vv -i .hosts.yml test-mounts-tasklist.pb.yml
```

### Ansible connectivity and authorization
* Real host definition filename starts with a dot so it will be gitignored out to keep password secret.
* Sudo currently requires a password on host.

Validate connection works:
```
$ ansible-playbook -vv  -i .hosts.yml validate-inventory.pb.yml
```


## Debugging - services and their output

Overview of units (Does not contain all logs):
```
$ sudo systemctl status 'seaweedfs_*'
```

Logs for a unit:
```
$ sudo journalctl -xe -b -u seaweedfs_mount_filerroot
```

Follow as new messages appear:
```
$ journalctl -xe -b -u seaweedfs_filer_2.service -f
```

```
$ journalctl --boot --pager-end --follow --since='5 minutes ago' --unit=seaweedfs_filer_3.service
```

```
$ journalctl --boot --pager-end --follow --since='5 minutes ago' --unit=seaweedfs_volume_foo
```

```
$ journalctl --boot --pager-end --follow --since='5 minutes ago' --unit=seaweedfs_s3api_1.service
```


Show all seaweedfs units at once in journalctl:
```
## Make arguments for units:
$ systemctl --no-legend list-unit-files "seaweedf*" | cut -d' ' -f1 | xargs systemd-escape | awk  '{print "-u"; print $0;}' RS=" " | tr '\n' ' '

## Give arguments to journalctl
$ journalctl --boot --pager-end --follow --since='5 minutes ago' $(systemctl --no-legend list-unit-files "seaweedf*" | cut -d' ' -f1 | xargs systemd-escape | awk  '{print "-u"; print $0;}' RS=" " | tr '\n' ' ' )
```


## Debugging - postgres
Try restarting the service:
```
$ sudo systemctl restart postgresql.service
```


### postgres - GRANTs
Fucking with privileges for authenticated users.
Don't rely on these to be completely correct.

```
GRANT CONNECT ON DATABASE "seaweedfs-filer" TO "seaweedfs";
GRANT USAGE ON DATABASE "seaweedfs-filer" TO "seaweedfs";
GRANT USAGE ON SCHEMA public TO "seaweedfs";
GRANT SELECT ON DATABASE "seaweedfs-filer" TO "seaweedfs";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "seaweedfs";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "seaweedfs";
```
* see https://medium.com/@swaplord/grant-read-only-access-to-postgresql-a-database-for-a-user-35c57897dd0b

```
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "seaweedfs";
```

* https://linuxhint.com/postgres-grant-all-privileges-on-schema-to-user/
```
GRANT CONNECT ON DATABASE "seaweedfs-filer" to "seaweedfs";
GRANT USAGE ON SCHEMA public TO Postgres;
GRANT ALL PRIVILEGES ON DATABASE "seaweedfs-filer" TO "seaweedfs";
GRANT ALL ON "filemeta" TO "seaweedfs";
```


### postgres - pg_hba.conf
Config file for postgres user authentication.
postgres may need to be restarted to apply changes to this.
Usually located at "/var/lib/pgsql/data/pg_hba.conf"


## weed shell
To open weed shell:
```
$ weed shell
```

To specify specific master/filer:
```
$ weed shell -master=localhost:9333 -filer=localhost:8888
```

You can send commands to STDIN:
```
$ weed shell <<< "volume.list"

$ echo "volume.list" | weed shell
```

HEREDOCs work as normal:
```
weed shell <<EOF
volume.list
lock
volume.check.disk
volume.fix.replication
unlock
EOF
```

More complicated pipelines are possible:
```bash
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
```

Two different ways to get help message, usually give different piecess of information.
```
> help COMMAND
> COMMAND -help
```

List volumes:
```
> volume.list
```

Creating a bucket:
```
> s3.bucket.create -name=asagi -replication 001
create bucket under /buckets
created bucket asagi
```


## Stress testing
`weed filer.copy`
* `Usage: weed filer.copy file_or_dir1 [file_or_dir2 file_or_dir3] http://localhost:8888/path/to/a/folder/`

Uploading a bunch of garbage:
```
## Dir to work in:
mkdir -vp "/home/ctrls/garbage/"

## Create garbage data:

## for n in {0..9}; do head -c "${size}" < /dev/urandom > "${junkdir}/${n}.${size}.junk" ; done; ## Random test
for n in {00..99}; do head -c "5M" < /dev/urandom > "/home/ctrls/garbage/${n}.5M.junk" ; done; ## Random test

## Disk device should spit out data faster than RNG.
head -c '100G' < /dev/sda > /home/ctrls/garbage/junkfile

## RAM dump should be super fast if we have privs to do that.
for n in {0..9}; do head -c "10G" < /dev/mem > "/home/ctrls/garbage/${n}.10G.junk" ; done;

## Bucket to throw garbage into:
weed shell <<< 's3.bucket.create -name=testing -replication 001'

## Upload the garbage
weed filer.copy /home/ctrls/garbage/ http://localhost:8888/buckets/testing/

$ weed filer.copy -replication=000 -check.size -debug /home/ctrls/garbage/ http://localhost:8888/buckets/testing/
```

Make more garbage files for testing:
```
for n in {00..99}; do head -c "5M" < /dev/urandom > "/home/ctrls/garbage/b${n}.5M.junk" ; done; ## Random test
```
$ for n in {000..999}; do head -c "5M" < /dev/urandom > "/home/ctrls/garbage/c${n}.5M.junk" ; done; ## Random test

Upload lots of uncompressible noise files via weed filer.copy:
```
$ mkdir -vp /home/ctrls/garbage/1M-a/
$ for n in {0000..9999}; do head -c "1M" < /dev/urandom > "/home/ctrls/garbage/1M-a/.1M.${n}.junk" ; done; ## Random test files.
$ time weed filer.copy -replication=001 -check.size -debug /home/ctrls/garbage/ http://localhost:8888/buckets/testing/
```

Create lots of uncompressible noise files in-place on weed mount:
```
$ mkdir -vp /weedmnt/filer-root/buckets/garbage/1M-a/
$ for n in {0000..9999}; do head -c "1M" < /dev/urandom > "/weedmnt/filer-root/buckets/garbage/1M-a/.1M.${n}.junk" ; done; ## Random test files.
```

Generate random garbage in 10M files:
```
$ mkdir -vp /weedmnt/filer-root/buckets/garbage/10M-a/
$ for n in {0000..9999}; do head -c "10M" < /dev/urandom > "/weedmnt/filer-root/buckets/garbage/10M-a/10M.${n}.junk" ; done; ## Random test files.
```

Stat every file in every bucket:
```
$ date;time du -hd0 /weedmnt/filer-root/buckets/
```


## Filer backups
Automatic backup of the filer can be done via
* `tasks/filer-meta-bkup-multidest.yml`
* `templates/backup-filer-multidest.cronjob.sh.j2`

Filer is saved to a temporary file, then that is copied to backup dirs.

Old backups are renamed to keep most recent 3 backups.

I figure a good place to put these is the HDDs the volumeservers use, since the point is largely to prevent any single disk failing from breaking anything.

vars.yml
```
filermeta_backup_tempdir: '/var/lib/seaweedfs/'
filermeta_backup_destdirs:
  - '/media/myhdd_1/seaweedfs-filer-backup'
  - '/media/myhdd_2/seaweedfs-filer-backup'
```


### Manually running filerbackup cronjob
To run the cronjob as the seaweedfs user:
```
$ sudo -u seaweedfs /var/lib/seaweedfs/scripts/backup-filer-multidest.cronjob.sh
```

To restore ownership if you forget to run as seaweedfs:
```
$ sudo chown -vR 420420:420420 /media/*/seaweedfs-filer-backup/
```


### Rclone backup upload
* Remember to add your rcone config file at `files/rclone.conf` so ansible can use it.

To adjust options for running rclone command:
```
## This will only work if the rclone job was started with the '--rc' argument!
$ rclone rc core/bwlimit rate=1M
{
        "bytesPerSecond": 1048576,
        "rate": "1M"
}
```


## Sanitycheck code
To do basic validation without having to actually run a deployment:
```bash
$ ansible-playbook --check main.pb.yml --skip-tags 'precautions,download'
```
Tag: `precautions` is protective filer backup etc done at playbook run time.
Tag: `download` is downloading seaweedfs and certstrap binaries from github.
