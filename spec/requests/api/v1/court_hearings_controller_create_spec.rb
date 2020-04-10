# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CourtHearingsController do
  let(:response_json) { JSON.parse(response.body) }

  context 'with swagger generation', :with_client_authentication, :rswag do
    path '/court_hearings' do
      post 'Creates a court hearing' do
        tags 'CourtHearings'
        consumes 'application/vnd.api+json'
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

        parameter name: :court_hearing,
                  description: 'The court hearing to create',
                  in: :body,
                  attributes: {
                    schema: '#/definitions/court_hearing/CourtHearing',
                  }

        let(:court_hearing) do
          {
            data: {
              type: 'court_hearings',
              attributes: {
                'start_time': '2018-01-01T18:57Z',
                'case_start_date': '2018-01-01',
                'case_number': 'T32423423423',
                'nomis_case_id': '4232423',
                'case_type': 'Adult',
                'comments': 'Witness for Foo Bar',
              },
            },
          }
        end

        response '201', 'created' do
          schema '$ref': '#/definitions/post_court_hearing_responses/201'

          run_test!
        end
      end
    end
  end
end
