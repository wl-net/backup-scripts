#!/bin/sh

#######################################
# WLNet External Drive backup system
# Last Updated: 2012-12-14
#######################################

# Configuration options
EXTERNAL_DRIVE=/media/datastore-ex-2

NOW=$(date +"%Y-%m-%d_%H-%M")
START_TIME=$(date +%s)

if [ ! -d "$EXTERNAL_DRIVE" ]; then
    echo "External drive not plugged in/mounted."
    exit 1
fi

echo "External Backup to ($EXTERNAL_DRIVE/Backups/$NOW) starting..."
cd /tmp #for caution

mkdir $EXTERNAL_DRIVE/Backups/$NOW 2> /dev/null
mkdir $EXTERNAL_DRIVE/$Backups/NOW/Documents/ 2> /dev/null

# Archived backups.
rsync -avh /home/andrew/Documents/ $EXTERNAL_DRIVE/Backups/$NOW/Documents/ --delete > /dev/null
rsync -avh /home/andrew/Projects/ $EXTERNAL_DRIVE/Backups/$NOW/Projects/ --delete > /dev/null
rsync -avh /home/andrew/Dropbox/ $EXTERNAL_DRIVE/Backups/$NOW/Dropbox/ --delete > /dev/null

# Mirrored backups.
rsync -avh /home/andrew/Music/ $EXTERNAL_DRIVE/Backups/Ongoing/Music/ --delete > /dev/null
rsync -avh /home/andrew/Videos/ $EXTERNAL_DRIVE/Backups/Ongoing/Videos/ --delete > /dev/null
rsync -avh /home/andrew/Pictures/ $EXTERNAL_DRIVE/Backups/Ongoing/Pictures/ --delete > /dev/null

touch $EXTERNAL_DRIVE/Backups/Ongoing/

sync

echo "New backup ($NOW) created. Deleting old backups in 10 seconds:"
ls $EXTERNAL_DRIVE/Backups/ -t | sed -e '1,10d'

sleep 10
echo "Deleting old backups..."
# Delete old backups.
cd $EXTERNAL_DRIVE/Backups/
ls $EXTERNAL_DRIVE/Backups/ -t | sed -e '1,10d' | xargs -d '\n' rm -r

sync

END_TIME=$(date +%s)
TOTAL_TIME=$(expr $END_TIME - $START_TIME)
echo -n "Backup completed in $TOTAL_TIME seconds"
exit 0

