#!/bin/bash
cd /usr/src/app

bundle exec rake db:create db:migrate
bundle exec puma -p $PUMA_PORT
