#!/bin/bash

# get the current directory
DIR=/Users/billdoughty/Backup/postgres
mkdir -p $DIR
cd $DIR

# boxes4 database
pg_dump -Fc boxes4_production > boxes4_production.dump
rsync -avz --progress boxes4_production.dump linair:./Backup/postgres