# frozen_string_literal: true

require 'rails_helper'

def load_swagger_yaml(path)
  YAML.safe_load(File.read(Rails.root.join('spec', 'swagger', path))).deep_symbolize_keys
end

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
      basePath: '/api/v1',
      openapi: '3.0.1',
      info: {
        title: 'PECS4 API V1 Docs',
        version: 'v1',
        description: 'Book A Secure Move supplier and frontend API.'
      },
      consumes: [
        'application/vnd.api+json'
      ],
      servers: [
        {
          url: 'http://localhost:3000/api/v1',
          description: 'Local development (localhost)'
        },
        {
          url: 'https://hmpps-book-secure-move-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1',
          description: 'Staging API'
        },
        {
          url: 'https://hmpps-book-secure-move-api-preprod.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1',
          description: 'PreProd API'
        },
        {
          url: 'https://api.bookasecuremove.service.justice.gov.uk/api/v1',
          description: 'Production API'
        }
      ],
      security: [
        {
          oauth2: []
        }
      ],
      components: {
        securitySchemes: {
          oauth2: {
            type: :oauth2,
            flows: {
              clientCredentials: {
                authorizationUrl: '/oauth/authorize',
                tokenUrl: '/oauth/token/',
                scopes: {}
              }
            }
          }
        }
      },
      definitions: {
        location_reference: load_swagger_yaml('definitions/location_reference.yaml'),
        move_object: load_swagger_yaml('definitions/move_object.yaml'),
        person_reference: load_swagger_yaml('definitions/person_reference.yaml')
      },
      paths: {}
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml

  config.after do |example|
    # We need to add the schema here _as well_ as the schema definition
    # to correctly generate the swagger-ui models.
    # See https://github.com/rswag/rswag/issues/268
    example.metadata[:response][:content] = { example.metadata[:operation][:produces].first => {
        schema: example.metadata[:response][:schema]
      }
    }
  end
end
