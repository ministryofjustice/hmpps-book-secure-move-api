FROM ruby:2.6.6-alpine as build-stage

ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="app/.bundle"

WORKDIR /app

RUN apk add git build-base tzdata postgresql-dev

COPY . /app
RUN gem update bundler --no-document
RUN bundle install --without="development test"  --jobs 4 --retry 3

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
ENV BUNDLE_APP_CONFIG="app/.bundle"

ENV PUMA_PORT 3000
EXPOSE $PUMA_PORT

RUN addgroup -g $APPUID -S appgroup && \
    adduser -u $APPUID -S appuser -G appgroup

RUN apk add tzdata postgresql-dev

WORKDIR /app
COPY --from=build-stage /usr/local/bundle /usr/local/bundle
COPY --from=build-stage /app /app

RUN  chown -R appuser:appgroup /app  && \
     chown -R appuser:appgroup /home/appuser

USER $APPUID
ENTRYPOINT ["./run.sh"]

