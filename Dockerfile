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

ENV APPUID 1000
USER $APPUID

ENTRYPOINT ["./run.sh"]
