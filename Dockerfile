FROM ruby:2.6.2-stretch

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE ${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}

ENV RAILS_ENV production
ENV PUMA_PORT 3000
EXPOSE $PUMA_PORT

WORKDIR /app

# ugrade bundler to 2.1.4
RUN gem update bundler --no-document

COPY . /app

RUN bundle install --verbose --without="development test" --jobs 4 --retry 3

# Run the application as user 1000
# directories/files need to be chowned otherwise we get Errno::EACCES
ENV APPUID 1000

RUN mkdir -p /home/appuser && \
  useradd appuser -u $APPUID --user-group --home /home/appuser && \
  chown -R appuser:appuser /app && \
  chown -R appuser:appuser /home/appuser

USER $APPUID

ENTRYPOINT ["./run.sh"]
