# hmpps-book-secure-move-api

This repository contains the backend API for the Book A Secure Move platform.

## Ruby versions and other dependencies

We typically use [asdf](https://asdf-vm.com/#/) or [rbenv](https://github.com/rbenv/rbenv) to install changing versions of ruby via the .ruby-version file.

If you have `rbenv` installed you can run `rbenv install $(cat .ruby-version)`.
If you have `asdf` with the ruby plugin installed you can run `asdf install`.

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
bundle exec rspec
```

We use Rubocop for code linting, to run the checks:

```bash
bundle exec rubocop
```

### Create reference data

To create reference data (seed data) needed in production run the
following rake task:

```bash
bundle exec rake reference_data:create_all
```

Some of these tasks pull data from NOMIS and therefore require
environment variables configured with the relevant security credentials.

These tasks are designed to be non-destructive. They can be run multiple
times and will only modify data if the original data source has changed.

### Create fake transactional data

To optionally create fake transactional data to use for testing and in a development environment run:

```
bundle exec rails fake_data:create_all
```

**NOTE:** This requires all reference data to be loaded before running using the above `reference_data:create_all` task.

### Populate Framework data

To create a framework and populate it's questions run the following rake task:

```bash
bundle exec rake frameworks:populate_data
```

This will pull in all tagged versions from the [Framework repository](https://github.com/ministryofjustice/hmpps-book-secure-move-frameworks) and persist the Framework Questions under the Framework version extracted from the Git tag. 

Alternatively, to specify a local Framework and version run the task with the following options:

```bash
bundle exec rake frameworks:populate_data['/path/to/hmpps-book-secure-move-frameworks/frameworks','1.1.1']
```

The path to the frameworks folder and the semantic version can be specified.

## Documentation

### Swagger API documentation

The `rswag` gem is used to generate swagger documentation for the API endpoints defined in `spec/swagger/swagger_doc_vN.yaml` where `N`
indicates the API version. All endpoints from API version 1 are included and overridden as required in the version 2 file. 

These files in turn reference more granular definitions of each entity and expected responses in `swagger/vN/*.yaml` files. Again,
definitions from version 1 are available for inclusion and overridden as needed in version 2 definitions.

**Note** that the Rswag rspec DSL is not used at all and instead endpoints are defined manually (this proved over time to be easier than
using the DSL).

Swagger documentation can be generated or updated by running:

```bash
  bundle exec rake rswag
```

or (both are equivalent)

```bash
  bundle exec rails rswag:specs:swaggerize
```

Swagger UI documentation can then be viewed at `http://localhost:3000/api-docs`.

The rake task needs to be run manually to see up to date documentation in local development environments and to reflect any changes made
to the `spec/swagger` files. Changes to other files under `swagger/vN` should be automatically picked up by reloading the Swagger UI page.

The task generates output files in `swagger/vN/swagger.yaml` - these are not tracked in git as they can be generated as needed and are
automatically created as part of the Circle CI build pipeline. Documentation can be downloaded via Swagger UI and imported into a REST
client such as Insomnia or Postman for easier manual API testing.

### Database schema

A database schema diagram can be generated by running:

```bash
bundle exec rake erd
```

This will output a file named `erd.pdf`; this file should not be added to git as it can be generated on demand.

Graphviz also needs to be installed (`brew install graphviz`) for this to work. For more details see: https://github.com/voormedia/rails-erd

## Continuous Integration

We use Circle CI for continuous integration: running tests, generating swagger documentation, updating the
Docker image and automatically deploying to development and staging environment:

[![CircleCI](https://circleci.com/gh/ministryofjustice/hmpps-book-secure-move-api)](https://circleci.com/gh/ministryofjustice/hmpps-book-secure-move-api)

## Deployment

This application is deployed to [Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/).

Currently we have a `dev`, `staging`, `uat`, `preprod` and `production` environments on Cloud
Platform with the following namespace names:

* hmpps-book-secure-move-api-dev
* hmpps-book-secure-move-api-staging
* hmpps-book-secure-move-api-uat
* hmpps-book-secure-move-api-preprod
* hmpps-book-secure-move-api-production

`dev` and `staging` environments are automatically deployed on successful builds of the
`master` branch on Circle CI.

`preprod`, `uat` and `production` can be deployed by generating a new tag
following [semantic versioning](https://semver.org/) pointing to the current commit. We typically do this locally with:

Deployments and associated commits are tracked in the service Sentry project.
The Git SHA is used to identify the release and is tracked  by means of the `SENTRY_RELEASE` environment variable in Dockerfile.
The associated commits are tracked by a CircleCI integration triggered on the deployment stage.

```bash
# Get a list of tags
git tag
# Tag following semantic versioning rules
git tag v1.0.1
# Push the tag to origin
git push origin v1.0.1
```

Tagged deploys are gated for the `production` environment and require an approval. This is typically done after
a review from a product owner where reasonable and if a hotfix is not necessary.

You'll want to login to CircleCI and navigate to the project build list to find the build that needs approving.

## Running in docker-compose locally.

You can run the build container locally using docker-compose.

```bash
# start the docker-compose stack in the background.
docker-compose up -d

# You can follow the logs by doing
docker-compose logs -f
```

You can force rebuilding the container with:

```bash
docker-compose build
```

You can review swagger documentation by navigating to `http://localhost:3000/api-docs/index.html`

If your database is fresh or was reset, you need to generate new application client credentials.
You can do this by running the respecive rake task inside the compose stack.

```bash
docker exec -it hmpps-book-secure-move-api_web_1 bundle exec rake auth:create_client_application NAME=test
```

The docker-compose stack also exposes the Postgres port to the host. You can update the reference data with:

```bash
export DATABASE_URL=postgresql://postgres:postgres@localhost:5432/hmpps-book-secure-move-api
bundle exec rake reference_data:create_all
```
