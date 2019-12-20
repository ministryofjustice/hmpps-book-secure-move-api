require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'PECS4 front-end API V1 Docs (auto-generated)',
        version: 'v1',
        description: 'Book A Secure Move supplier and frontend API.'
      },
      consumes: [
        "application/vnd.api+json"
      ],
      servers: [
        {
          url: "http://localhost:3000/api/v1",
          description: "Local development (localhost)"
        },
        {
          url: "https://hmpps-book-secure-move-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1",
          description: "Staging API"
        },
        {
          url: "https://hmpps-book-secure-move-api-preprod.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1",
          description: "PreProd API"
        },
        {
          url: "https://api.bookasecuremove.service.justice.gov.uk/api/v1",
          description: "Production API"
        }
      ],
      security: [
        {
          pecsAuth: []
        }
      ],
      components: {
        securitySchemes: {
          pecsAuth: {
            type: "oauth2",
            flows: {
              clientCredentials: {
                authorizationUrl: "/oauth/authorize",
                tokenUrl: "/oauth/token/",
                scopes: {}
              }
            }
          }
        }
      },
      paths: {}
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
