#!/bin/sh

#######################################
# WLNet External Drive backup system
# Last Updated: 2013-01-26
#######################################

# Configuration options
EXTERNAL_DRIVE=/run/media/andrew/datastore-ex-1

NOW=$(date +"%Y-%m-%d_%H-%M")
START_TIME=$(date +%s)
START_WORKING_PATH=$(pwd)

if [ ! -d "$EXTERNAL_DRIVE" ]; then
    echo "External drive not plugged in/mounted."
    exit 1
fi

trap "echo ' aborting backup'; cd $START_WORKING_PATH; exit" SIGINT SIGTERM

echo "External Backup to ($EXTERNAL_DRIVE/Backups/$NOW) starting..."
cd /tmp #for caution

mkdir $EXTERNAL_DRIVE/Backups/$NOW 2> /dev/null

# Archived backups.
rsync -avh /home/andrew/Documents/ $EXTERNAL_DRIVE/Backups/$NOW/Documents/ --delete > /dev/null
rsync -avh /home/andrew/Projects/ $EXTERNAL_DRIVE/Backups/$NOW/Projects/ --delete > /dev/null
rsync -avh /home/andrew/Dropbox/ $EXTERNAL_DRIVE/Backups/$NOW/Dropbox/ --delete > /dev/null

# Mirrored backups.
rsync -avh /home/andrew/Music/ $EXTERNAL_DRIVE/Backups/Ongoing/Music/ --delete > /dev/null
rsync -avh /home/andrew/Music/Podcasts/ $EXTERNAL_DRIVE/Backups/Ongoing/Podcasts/ --delete > /dev/null
rsync -avh /home/andrew/Videos/ $EXTERNAL_DRIVE/Backups/Ongoing/Videos/ --delete > /dev/null
rsync -avh /home/andrew/Pictures/ $EXTERNAL_DRIVE/Backups/Ongoing/Pictures/ --delete > /dev/null
rsync -avh /home/andrew/.Applications/ $EXTERNAL_DRIVE/Backups/Ongoing/Applications/ --delete > /dev/null

touch $EXTERNAL_DRIVE/Backups/Ongoing/

sync

echo "New backup ($NOW) created. Deleting old backups in 10 seconds:"

# Delete old backups.
cd $EXTERNAL_DRIVE/Backups/

if [ $(ls $EXTERNAL_DRIVE/Backups/ -lt | sed -e '1,10d' | wc -l) -ne 0 ]; then
    ls $EXTERNAL_DRIVE/Backups/ -lt | awk '{print $9}' | sed -e '1,10d'
    sleep 10
    echo "Deleting old backups..."
    ls $EXTERNAL_DRIVE/Backups/ -lt | awk '{print $9}' | sed -e '1,10d' | xargs -d '\n' rm -r
else
    echo "No backups to delete (threshold not met), skipping"
fi

sync

END_TIME=$(date +%s)
TOTAL_TIME=$(expr $END_TIME - $START_TIME)
echo "Backup completed in $TOTAL_TIME seconds"
cd $START_WORKING_PATH
exit 0
