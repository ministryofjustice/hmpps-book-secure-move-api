# PECS 4 Move Platform Back-end

This repository contains the backend API for Prisoner Escort and
Custody Services 4.

## Ruby versions and other dependencies

* Ruby version
    * Ruby version 2.6
    * Rails 5.2

* System dependencies
    * postgres
    * redis

## Development Environment setup

To setup the local development environment:

1. Install Postgres and Redis if needed.
2. Clone this Git repository.
3. Run `bin/setup` to install Rubygem dependencies, then setup local
   test and development databases etc.

You should then be able to run the local Web server:

    bundle exec rails server

### Running tests

We use RSpec for testing, to run the tests:

    bundle exec rspec spec

We use Rubocop for code linting, to run the checks:

    bundle exec rubocop

## Continuous Integration

We use Circle CI for continuous integration: running tests, updating the
Docker image, pushing code staging:

[![CircleCI](https://circleci.com/gh/ministryofjustice/pecs-move-platform-backend)](https://circleci.com/gh/ministryofjustice/pecs-move-platform-backend)

## Deployment

This application is deployed to [Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/).

Currently we have only one `staging` environment that is automatically
deployed on successful builds of the `master` branch on Circle CI.

