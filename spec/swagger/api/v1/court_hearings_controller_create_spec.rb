# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe Api::V1::CourtHearingsController, :with_client_authentication, :rswag, type: :request do
  let(:response_json) { JSON.parse(response.body) }

  path '/court_hearings' do
    post 'Creates a court hearing' do
      tags 'Court Hearings'
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

      parameter name: :do_not_save_to_nomis,
          in: :query,
          description: 'Restrict creating the court hearing in Nomis as well as Book A Secure Move',
          schema: { type: :string, default: 'false', example: 'true', enum: %w[true false] },
          required: false

      parameter name: :body,
        description: 'The court hearing to create',
        in: :body,
        schema: {
          type: 'object',
          properties: {
            data:  {
              type: 'object',
              properties: {
                type: {
                  type: 'string',
                  enum: %w[court_hearings],
                },
                attributes: {
                  type: 'object',
                  required: %w[start_time],
                  properties: {
                    start_time: {
                      type: 'string',
                      format: 'date-time',
                      example: '2018-01-01T18:57Z',
                      description: 'ISO8601 compatible timestamp',
                    },
                    case_number: {
                      type: 'string',
                      example: 'T32423423423',
                      description: 'The third party reference for the case of the current hearing',
                    },
                    nomis_case_id: {
                      type: 'integer',
                      example: 4232423,
                      description: 'The nomis reference for the case of the current hearing.',
                    },
                    case_type: {
                      type: 'string',
                      example: 'Adult',
                      enum: %w[Adult],
                      description: 'The type of the court that the court hearing is being held in.',
                    },
                    comments: {
                      type: 'string',
                      example: 'Witness for Joe Bloggs in Foo Bar court hearing.',
                      description: 'Arbitrary comments that are useful for humans but not touched by computers.',
                    },
                    case_start_date: {
                      type: 'string',
                      format: 'date',
                      example: '2020-01-01',
                      description: 'ISO8601-compatible date indicating when the case started.',
                    },
                  },
                },
                relationships: {
                  type: 'object',
                  properties: {
                    move: { '$ref' => 'move_reference.yaml#/MoveReference' },
                  },
                },
              },
            },
          },
        }

      let(:body) do
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
        schema '$ref' => 'post_court_hearing_responses.yaml#/201'

        run_test!
      end
    end
  end
end
