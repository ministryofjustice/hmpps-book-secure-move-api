#!/bin/bash

# Sadly toml files don't support inline expansion of environment variables
bundle exec erb config/application_insights.erb >config/application_insights.toml
bundle exec rake db:create db:migrate
bundle exec puma -p $PUMA_PORT
