#!/bin/bash
cd /usr/src/app

bundle exec puma -p $PUMA_PORT
