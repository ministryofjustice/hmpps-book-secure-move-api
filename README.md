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

### Running the application

After setup should then be able to run the local Web server:

```bash
bundle exec rails server
```

### Creating client credentials

The application implements OAuth2 client credentials flow. To generate new application client credentials, use the following Rake task:

```bash
bundle exec rake auth:create_client_application NAME=test
```

Please note; the automatically generated secret is hashed and cannot be retrieved later.

To get an access token with client credentials flow, do a POST request to the `/oauth/token` endpoint:

```
POST /oauth/token
Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW
Content-Type: application/x-www-form-urlencoded;charset=UTF-8
grant_type=client_credentials
```

The Authorization header includes the encoded credentials for the client, represented as a Base64-encoded (without line breaks) string of the form `<client_id>:<client_secret>`.

You will receive a JSON payload containing an `access_token` and `expires_in`. You can then sign following requests with the following header:

```
Authorization: Bearer <access_token>
```

The `expires_in` response denotes the time in seconds from the token request after which the token will expire.

### Running tests

We use RSpec for testing, to run the tests:

```bash
bundle exec rspec spec
```

We use Rubocop for code linting, to run the checks:

```bash
bundle exec rubocop
```

### Create fake data

To create fake data to use for testing run:

```
bundle exec rails fake_data:recreate_all
```

**Note:** This will delete all existing data

## Continuous Integration

We use Circle CI for continuous integration: running tests, updating the
Docker image, pushing code staging:

[![CircleCI](https://circleci.com/gh/ministryofjustice/pecs-move-platform-backend)](https://circleci.com/gh/ministryofjustice/pecs-move-platform-backend)

## Deployment

This application is deployed to [Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/).

Currently we have only one `staging` environment that is automatically
deployed on successful builds of the `master` branch on Circle CI.
