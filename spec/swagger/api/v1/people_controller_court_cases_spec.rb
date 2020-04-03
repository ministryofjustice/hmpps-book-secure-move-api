# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::PeopleController, :rswag, :with_client_authentication, type: :request do
  path '/people/{id}/court_cases' do
    get 'retrieves court cases related to a person' do
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

      parameter name: :id,
                in: :path,
                description: 'The ID of the person',
                schema: {
                    type: :string,
                },
                format: 'uuid',
                example: '00525ecb-7316-492a-aae2-f69334b2a155',
                required: true

      response '200', 'success' do
        let(:id) { person.id }
        let(:person) { create(:profile, :nomis_synced).person }
        let(:court_cases_from_nomis) {
          [CourtCase.new.build_from_nomis('caseInfoNumber' => 'T20167984', 'beginDate' => '2020-01-01', 'agency' => { 'agencyId' => "SNARCC" }),
           CourtCase.new.build_from_nomis('caseInfoNumber' => 'T22222222', 'beginDate' => '2020-01-02', 'agency' => { 'agencyId' => "SNARCC" })]
        }

        before do
          allow(People::RetrieveCourtCases).to receive(:call).with(person).and_return(court_cases_from_nomis)
        end

        schema "$ref": '#/definitions/get_court_cases_responses/200'
        run_test!
      end

      # response '404', 'not found' do
      #   let(:id) { 'invalid-id' }
      #
      #   run_test!
      # end
    end
  end
end
