#!/bin/sh

oldest_backup_id=$(heroku pgbackups | grep DATABASE_URL | awk '{print $1}' | tail -r | tail -1)
echo "destroying oldbest backup id $oldest_backup_id"
heroku pgbackups:destroy $oldest_backup_id
heroku pgbackups:capture
curl -o tmp/latest.dump `heroku pgbackups:url`