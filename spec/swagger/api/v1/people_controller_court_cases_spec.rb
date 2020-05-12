# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::PeopleController, :rswag, :with_client_authentication, type: :request do
  path '/people/{person_id}/court_cases' do
    get 'Retrieves the active court cases related to a person. It filters out the non-active court cases.' do
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
      parameter name: :'filter[active]',
                in: :query,
                description: 'Filter only active court cases.',
                schema: { type: :string, default: 'true', example: 'false', enum: %w[true false] },
                required: false

      response '200', 'success' do
        let(:person_id) { person.id }
        let(:person) { create(:profile, :nomis_synced).person }
        let(:court_cases_from_nomis) {
          court_case = CourtCase.new.build_from_nomis(
            'id' => '1495077',
            'caseSeq' => 1,
            'beginDate' => '2020-01-01',
            'agency' => { 'agencyId' => 'SNARCC' },
            'caseType' => 'Adult',
            'caseInfoNumber' => 'T20167984',
            'caseStatus' => 'ACTIVE',
          )

          [court_case]
        }

        before do
          allow(People::RetrieveCourtCases).to receive(:call).with(person, nil).and_return(OpenStruct.new(success?: true, court_cases: court_cases_from_nomis))
        end

        schema '$ref' => 'get_court_cases_responses.yaml#/200'

        run_test!
      end

      response '404', 'not found' do
        let(:person_id) { 'invalid-id' }

        run_test!
      end

      response '422', 'unprocessable entity' do
        let(:person_id) { person.id }
        let(:person) { create(:profile).person } # since it is not nomis_synced latest_nomis_booking_id is nil

        schema '$ref' => 'get_court_cases_responses.yaml#/400'

        run_test!
      end
    end
  end
end
