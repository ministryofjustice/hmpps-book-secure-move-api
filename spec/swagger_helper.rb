# frozen_string_literal: true

require 'rails_helper'

def swagger_file(*relative_path)
  File.read(Rails.root.join('spec', 'swagger', 'definitions', *relative_path))
end

def load_swagger_yaml(*relative_path)
  YAML.safe_load(swagger_file(*relative_path))
end

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'

  swagger_doc_v1 = YAML.load_file('spec/swagger/swagger_doc_v1.yaml')
  swagger_doc_v2 = YAML.load_file('spec/swagger/swagger_doc_v2.yaml')
  swagger_doc_base = YAML.load_file('spec/swagger/swagger_doc_base.yaml')

  swagger_doc_v2_integration = swagger_doc_v1.deep_dup

  swagger_doc_v2_integration.deep_merge!(swagger_doc_v2)

  config.openapi_specs = {
    'v1/swagger.yaml' => swagger_doc_v1,
    'v2/swagger.yaml' => swagger_doc_v2_integration,
    'base/swagger.yaml' => swagger_doc_base,
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml

  config.after do |example|
    # if there's no response metadata, we can assume we're not in RSwag territory
    unless example.metadata[:response].nil?

      # We need to add the schema here _as well_ as the schema definition
      # to correctly generate the swagger-ui models.
      # See https://github.com/rswag/rswag/issues/268
      example.metadata[:response][:content] = {
        example.metadata[:operation][:produces].first => {
          schema: example.metadata[:response][:schema],
        },
      }

      # Save actual responses as examples for Swagger UI
      # example.metadata[:response][:examples] = {
      #   example.metadata[:operation][:produces].first => JSON.parse(response.body, symbolize_names: true)
      # }
    end
  end
end
