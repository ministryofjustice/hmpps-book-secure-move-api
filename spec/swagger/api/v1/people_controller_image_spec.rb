# frozen_string_literal: true

# TODO move Swagger to hand_coded_paths.yaml
# TODO move to controller spec

require 'swagger_helper'


RSpec.describe Api::V1::PeopleController, :rswag, :with_client_authentication, type: :request do
  path '/people/{person_id}/images' do
    get 'retrieves an image' do
      tags 'People'
      produces 'application/vnd.api+json'

      parameter name: :Authorization,
                in: :header,
                schema: {
                  type: 'string',
                  default: 'Bearer <your-client-token>',
                },
                required: true,
                description: <<~DESCRIPTION
                  This is "Bearer ", followed by your OAuth 2 Client token.
                  If you're testing interactively in the web UI, you can ignore this field
                DESCRIPTION

      parameter name: 'Content-Type',
                in: 'header',
                description: 'Accepted request content type',
                schema: {
                  type: 'string',
                  default: 'application/vnd.api+json',
                },
                required: true

      parameter name: :person_id,
                in: :path,
                description: 'The ID of the person',
                schema: {
                  type: :string,
                },
                format: 'uuid',
                example: '00525ecb-7316-492a-aae2-f69334b2a155',
                required: true

      response '200', 'success' do
        let(:person_id) { create(:profile, :nomis_synced).person.id }
        let(:image_data) { File.read('spec/fixtures/Arctic_Tern.jpg') }

        before do
          allow(NomisClient::Image).to receive(:get).and_return(image_data)
        end

        run_test!
      end

      response '404', 'not found' do
        let(:person_id) { 'invalid-id' }

        run_test!
      end

      response '422', 'unprocessable entity' do
        let(:person_id) { person.id }
        let(:person) { create(:profile).person }

        run_test!
      end
    end
  end
end
