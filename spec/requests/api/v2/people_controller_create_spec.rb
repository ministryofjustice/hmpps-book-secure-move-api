# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::PeopleController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }

  describe 'POST /people' do
    let(:schema) { load_yaml_schema('post_people_responses.yaml', version: 'v2') }

    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:risk_type_1) { create :assessment_question, :risk }
    let(:risk_type_2) { create :assessment_question, :risk }

    let(:person_params) do
      {
        data: {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1),
            gender_additional_information: 'info about Bob',
          },
          relationships: {
            ethnicity: {
              data: {
                id: ethnicity.id,
                type: 'ethnicities',
              },
            },
            gender: {
              data: {
                id: gender.id,
                type: 'genders',
              },
            },
          },
        },
      }
    end

    context 'when successful' do
      let(:expected_data) do
        {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.civil(1980, 1, 1).iso8601,
            gender_additional_information: 'info about Bob',
          },
          relationships: {
            gender: {
              data: {
                type: 'genders',
                id: gender.id,
              },
            },
            ethnicity: {
              data: {
                type: 'ethnicities',
                id: ethnicity.id,
              },
            },
          },
        }
      end

      let(:expected_included) do
        []
      end

      context 'with valid params' do
        before { post '/api/v2/people', params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with success 201'
      end

      it 'returns the correct data' do
        post '/api/v2/people', params: person_params, headers: headers, as: :json

        expect(response_json).to include_json(data: expected_data.merge(id: Person.last.id))
      end

      describe 'include query param' do
        before do
          post "/api/v2/people#{query_params}", params: person_params, headers: headers, as: :json
        end

        context 'when including multiple relationships' do
          let(:query_params) { '?include=gender,ethnicity' }

          it 'includes the correct relationships' do
            expect(response_json['included'].count).to eq(2)
            expect(response_json['included']).to include_json([{ type: 'ethnicities' }, { type: 'genders' }])
          end
        end

        context 'when does NOT include any relationship' do
          let(:query_params) { '' }

          it 'does NOT include any relationships' do
            expect(response_json).not_to include('included')
          end
        end

        context 'when including a non existing relationship' do
          let(:query_params) { '?include=gender,non-existent-relationship' }

          it 'responds with error 400' do
            response_error = response_json['errors'].first

            expect(response_error['title']).to eq('Bad request')
            expect(response_error['detail']).to include('["non-existent-relationship"] is not supported.')
          end
        end
      end

      it 'creates a new person' do
        expect {
          post '/api/v2/people', params: person_params, headers: headers, as: :json
        }.to change(Person, :count).by(1)
      end

      describe 'webhook and email notifications' do
        # TODO: verify if the to trigger prepare_notifications even in V2
        # and consider that this implementation does not validate any Person's attributes for now (explicitly required)
        before do
          allow(Notifier).to receive(:prepare_notifications)
          post '/api/v2/people', params: person_params, headers: headers, as: :json
        end

        it 'does NOT call the notifier when creating a person' do
          expect(Notifier).not_to have_received(:prepare_notifications)
        end
      end

      context 'with a bad request' do
        before { post '/api/v2/people', params: {}, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with error 400'
      end

      context 'when not authorized', :with_invalid_auth_headers do
        let(:detail_401) { 'Token expired or invalid' }
        let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
        let(:content_type) { ApiController::CONTENT_TYPE }

        before { post '/api/v2/people', params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with error 401'
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:content_type) { 'application/xml' }

        before { post '/api/v2/people', params: person_params, headers: headers, as: :json }

        it_behaves_like 'an endpoint that responds with error 415'
      end
    end
  end
end
