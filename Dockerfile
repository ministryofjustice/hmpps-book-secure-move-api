FROM ministryofjustice/ruby:2.6.2-webapp-onbuild

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}

ENV RAILS_ENV production
ENV PUMA_PORT 3000
EXPOSE $PUMA_PORT

# Run the application as user `moj` (created in the base image)
# uid=1000(moj) gid=1000(moj) groups=1000(moj)
# Some directories/files need to be chowned otherwise we get Errno::EACCES
#
# RUN chown $APPUSER:$APPUSER ./db/schema.rb

RUN curl -sL https://deb.nodesource.com/setup_13.x | bash - \
   && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
   && apt-get update \
   && apt-get install -y nodejs yarn \
   && apt-get clean

RUN yarn install
# Have to set SECRET_KEY_BASE here to arbitrary string, otherwise task doesn't run
RUN SECRET_KEY_BASE=valuenotactuallyused rails assets:precompile

ENV APPUID 1000
# Need to do this as the app writes to tmp/cache and everything is setup as root
RUN chown -R $APPUID:$APPUID /usr/src/app/tmp/cache
USER $APPUID

ENTRYPOINT ["./run.sh"]
