#!/usr/bin/env bash

# exit when any command fails
set -e

# check if env vars are set
for var in ORIGIN_DB_HOST DESTINATION_DB_HOST ORIGIN_DB_USER ORIGIN_DB_NAME; do
    if [ -z "${!var}" ]; then
        echo "$var is not set!"
        exit 1
    fi
done 

# check if ORIGIN_DB_HOST is different from DESTINATION_DB_HOST
if [ "$ORIGIN_DB_HOST" = "$DESTINATION_DB_HOST" ]; then
    echo "ORIGIN_DB_HOST and DESTINATION_DB_HOST must be different!"
    exit 1
fi

# prompt for confirmation showing origin and destination
echo "Origin: $ORIGIN_DB_HOST"
echo "Destination: $DESTINATION_DB_HOST"
echo "Database: $ORIGIN_DB_NAME"
read -p "Are you sure you want to migrate from $ORIGIN_DB_HOST to $DESTINATION_DB_HOST? (y/n) " -n 1 -r
echo



export PGPASSFILE=/usr/src/.pgpass
# Prompt for password
read -s -p "Enter database password: " password
echo
# Create .pgpass file
echo "*:*:*:$ORIGIN_DB_USER:$password" > $PGPASSFILE
# Set appropriate permissions for .pgpass file
chmod 600 $PGPASSFILE
echo "Password saved in .pgpass file."

#set base path
basepath="data"
mkdir -p $basepath

# determine file name
datetime=`date +"%Y%m%d"`
filename_structure="$basepath/$ORIGIN_DB_NAME-$datetime-structure.sql"
filename_constraints="$basepath/$ORIGIN_DB_NAME-$datetime-constraints.sql"
filename_data="$basepath/$ORIGIN_DB_NAME-$datetime-data.sql"


echo "Dumping structure..."   
pg_dump -s -h $ORIGIN_DB_HOST -U $ORIGIN_DB_USER $ORIGIN_DB_NAME --exclude-schema='rds*' --section=pre-data --no-password > $filename_structure

echo "Dumping constraints..."  
pg_dump -s -h $ORIGIN_DB_HOST -U $ORIGIN_DB_USER $ORIGIN_DB_NAME --exclude-schema='rds*' --section=post-data --no-password > $filename_constraints

echo "Dumping data..."
pg_dump -Fc -h $ORIGIN_DB_HOST -U $ORIGIN_DB_USER $ORIGIN_DB_NAME --exclude-schema='rds*' --section=data --no-password > $filename_data

echo "Dumping complete."


echo "Restoring structure..."
createdb -h $DESTINATION_DB_HOST -U $ORIGIN_DB_USER $ORIGIN_DB_NAME
psql -h $DESTINATION_DB_HOST -U $ORIGIN_DB_USER $ORIGIN_DB_NAME --no-password < $filename_structure

echo "Restoring data..."
pg_restore -h $DESTINATION_DB_HOST -U $ORIGIN_DB_USER -d $ORIGIN_DB_NAME --no-password $filename_data

echo "Restoring constraints..."
psql -h $DESTINATION_DB_HOST -U $ORIGIN_DB_USER $ORIGIN_DB_NAME --no-password < $filename_constraints

echo "Restoring complete."
    
