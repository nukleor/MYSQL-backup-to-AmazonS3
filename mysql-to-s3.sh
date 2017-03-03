#!/bin/bash
# Shell script to backup MySql database

# CONFIG - Only edit the below lines to setup the script
# ===============================

MyUSER="root"           # USERNAME
MyPASS="password"       # PASSWORD
MyHOST="localhost"      # Hostname

S3Bucket="mysql-backup" # S3 Bucket

# DO NOT BACKUP these databases
IGNORE="test"

# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
# ===============================

# Linux bin paths, change this if it can not be autodetected via which command
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"

# Backup Dest directory, change this if you have someother location
DEST="/backup"

# Main directory where backup will be stored
MBD="$DEST/mysql-$(date +"%d-%m-%Y_%T")"

# Get hostname
HOST="$(hostname)"

# Get data in dd-mm-yyyy format
NOW="$(date +"%d-%m-%Y")"

# File to store current backup file
FILE=""

# Store list of databases
DBS=""

[ ! -d $MBD ] && mkdir -p $MBD || :

# Only root can access it!
$CHOWN 0.0 -R $DEST
$CHMOD 0600 $DEST

# Get all database list first

if [ "$MyPASS" == "" ];
then
  DBS="$($MYSQL -u $MyUSER -h $MyHOST -Bse 'show databases')"
else
  DBS="$($MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse 'show databases')"
fi

for db in $DBS
do
    skipdb=-1
    if [ "$IGNORE" != "" ];
    then
        for i in $IGNORE
        do
            [ "$db" == "$i" ] && skipdb=1 || :
        done
    fi

    if [ "$skipdb" == "-1" ] ; then
        FILE="$MBD/$db.$HOST.$NOW.gz"
        # dump database to file and gzip
        if [ "$MyPASS" == "" ]; then
          $MYSQLDUMP -u $MyUSER -h $MyHOST $db | $GZIP -9 > $FILE
        else
          $MYSQLDUMP -u $MyUSER -h $MyHOST -p$MyPASS $db | $GZIP -9 > $FILE
        fi
    fi
done

# copy mysql backup directory to S3
s3cmd sync -rv --skip-existing $MBD s3://$S3Bucket/
