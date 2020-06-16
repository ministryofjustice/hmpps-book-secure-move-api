FROM ruby:2.6.6-alpine as build-stage

ENV RAILS_ENV=production
ENV RACK_ENV=production

ENV BUNDLE_WITHOUT="development:test"
ENV BUNDLE_FROZEN="true"

WORKDIR /app
RUN apk --update --no-cache add git build-base postgresql-dev

COPY . /app
RUN gem update bundler --no-document
RUN bundle install --jobs 4 --retry 3 \
     && rm -rf /usr/local/bundle/cache/*.gem \
     && find /usr/local/bundle/gems/ -name "*.c" -delete \
     && find /usr/local/bundle/gems/ -name "*.o" -delete

############### End of Build step ###############
FROM ruby:2.6.6-alpine

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}

ENV APPUID 1000

ENV RAILS_ENV production
ENV RACK_ENV production

ENV PUMA_PORT 3000
EXPOSE $PUMA_PORT

RUN addgroup -g $APPUID -S appgroup && \
    adduser -u $APPUID -S appuser -G appgroup -h /app

RUN apk add --update --no-cache tzdata postgresql-dev

WORKDIR /app
COPY --chown=appuser:appgroup --from=build-stage /app /app
COPY --chown=appuser:appgroup --from=build-stage /usr/local/bundle /usr/local/bundle

USER $APPUID
CMD ["./run.sh"]

