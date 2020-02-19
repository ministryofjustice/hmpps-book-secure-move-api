#!/bin/bash
cd /usr/src/app

bundle exec rake db:create db:migrate
# Sadly toml files don't support inline expansion of environment variables
sed -i .bak s/APPINSIGHTS_INSTRUMENTATION_KEY/$APPINSIGHTS_INSTRUMENTATION_KEY/ config/application_insights.toml
bundle exec puma -p $PUMA_PORT
