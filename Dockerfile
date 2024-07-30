FROM ruby:3.2.5-alpine as build-stage

ENV RAILS_ENV=production
ENV RACK_ENV=production

ENV BUNDLE_WITHOUT="development:test"
ENV BUNDLE_FROZEN="true"

WORKDIR /app
RUN apk --update --no-cache add git build-base postgresql-dev shared-mime-info
RUN gem update bundler --no-document

# NB: its more efficient not to copy the full app folder until after the gems are installed (reduces unnecessary rebuilds)
COPY Gemfile Gemfile.lock .ruby-version /app/

RUN gem install bundler -v '2.1.4'

RUN bundle _2.1.4_ install --jobs 4 --retry 3 \
     && rm -rf /usr/local/bundle/cache/*.gem \
     && find /usr/local/bundle/gems/ -name "*.c" -delete \
     && find /usr/local/bundle/gems/ -name "*.o" -delete

############### End of Build step ###############
FROM ruby:3.2.5-alpine as swagger-build

WORKDIR /app
RUN apk --update --no-cache add git build-base postgresql-dev shared-mime-info gcompat tzdata
RUN gem update bundler --no-document

COPY Gemfile Gemfile.lock .ruby-version /app/
RUN bundle install --jobs 4 --retry 3

COPY . /app
RUN SKIP_MAINTAIN_TEST_SCHEMA=true rails rswag:specs:swaggerize

############### End of Build step ###############
FROM ruby:3.2.5-alpine

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}
ENV SENTRY_RELEASE ${APP_GIT_COMMIT}

ENV APPUID 1000

ENV RAILS_ENV production
ENV RACK_ENV production

ENV PUMA_PORT 3000
EXPOSE $PUMA_PORT

RUN addgroup -g $APPUID -S appgroup && \
    adduser -u $APPUID -S appuser -G appgroup -h /app

RUN apk add --update --no-cache git tzdata postgresql-dev shared-mime-info

WORKDIR /app
COPY --chown=appuser:appgroup --from=build-stage /usr/local/bundle /usr/local/bundle
COPY --chown=appuser:appgroup . /app
COPY --chown=appuser:appgroup --from=swagger-build /app/swagger/v1/swagger.yaml /app/swagger/v1/swagger.yaml
COPY --chown=appuser:appgroup --from=swagger-build /app/swagger/v2/swagger.yaml /app/swagger/v2/swagger.yaml

USER $APPUID
CMD bundle exec puma -p $PUMA_PORT
