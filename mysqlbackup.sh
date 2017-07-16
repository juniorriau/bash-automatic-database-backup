#!/bin/bash
###################################################################
###############       Automatic Mysql Backup       ################
###############       juniorriau18@gmail.com       ################
###################################################################

# MySQL User
USER="root"
# MySQL Password
PASS="hafizh"
# MySQL Host
HOST="localhost"
# Backup Directory
DIR="/home/hafizh/mysqlbackup"
# Backup Date
DATE=$(date +"%d-%b-%Y")
# Baackup Hour
HOURS=$(date +"%H-00")
# Backup Retain
RETAIN=2
# Backup Expire Day / Hour
EXP=2
# Day to Expire. Set to 0 if you choose expire by hour and set HOUR to n hours
DAY=0
# Hour to Expire. Set to 0 if you choose expire by day and set DAY to n days
HOUR=1
# Get MySQL Binary full path
MYSQL=$(which mysql)
MYSQLDUMP=$(which mysqldump)
LOG="mysql-backup.log"

echo "Starting Backup ..."
# Check Backup Directory is exist and create it if not exist
if [ ! -d $DIR ]
then
    echo "Directory does not exist! Creating backup directory ..."
    mkdir -p $DIR
    echo "Directory created successfully!" >> $DIR/$LOG
    echo "+++++++++++++++++++++++++++++++++++++++++++++++"
    echo "Starting MySQL Backup" >> $DIR/$LOG
else 
    echo "" > $DIR/$LOG
    echo "Starting MySQL Backup" >> $DIR/$LOG
fi

# Checking MySQL Password
echo "\n" >> $DIR/$LOG
echo "Checking MySQL Login ..." >> $DIR/$LOG
echo exit | mysql --user=$USER --password=$PASS -B 2>/dev/null
if [ "$?" -gt 0 ]; then
  echo "MySQL ${mysql_user} password incorrect" >>  $DIR/$LOG
  exit 1
else
  echo "MySQL ${mysql_user} password correct."  >> $DIR/$LOG
fi

# Backup Databases
echo "\n">> $DIR/$LOG
echo "Creating database directory ..." >> $DIR/$LOG
mkdir -p $DIR/$DATE/$HOURS

#for db in $($MYSQL --user=$USER --password=$PASS -e 'show databases' | egrep -ve 'Database|schema|test|phpmyadmin')
#do
#    echo "Backup database $db" >> $DIR/$LOG
#    $MYSQLDUMP  --user=$USER --password=$PASS --host=$HOST $db | gzip > $DIR/$DATE/$HOURS/$db.sql.gz
#    sleep 1
#done

echo "Creating Backup MySQL Done ..." >> $DIR/$LOG
echo "Checking expire backup ..." >> $DIR/$LOG
# Checking expire backup
if [ $DAY != 0 ]; then
    echo "Expire by Day. Searching expire files " >> $DIR/$LOG
    for file in $(cd $DIR; find ./ -mindepth 2 -type d -mtime +$[$RETAIN*$DAY])
    do
        if [ $file === "" ]; then
            break;
        else
            echo "Removing $file" >> $DIR/$LOG
            rm -rf $file
        fi
    done;
else
    echo "Expire by Hours. Searching expire files" >> $DIR/$LOG
    for file in $(find $DIR/ -mindepth 2 -type d -mmin +$[$HOUR*10])
    do
        if [ $file === "" ]; then
            break;
        else
            echo "Removing $file" >> $DIR/$LOG
            rm -rf $file
        fi
    done;
fi
echo "Backup done. Exiting ..."
exit 1
