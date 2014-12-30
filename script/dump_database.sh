#!/bin/sh

heroku pgbackups:capture
curl -o tmp/latest.dump `heroku pgbackups:url`