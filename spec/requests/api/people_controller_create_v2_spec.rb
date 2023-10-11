# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'POST /people' do
    let(:schema) { load_yaml_schema('post_people_responses.yaml', version: 'v2') }

    let(:ethnicity_id) { create(:ethnicity).id }
    let(:gender_id) { create(:gender).id }

    let(:person_params) do
      {
        data: {
          type: 'people',
          attributes: {
            first_names: 'Bob',
            last_name: 'Roberts',
            date_of_birth: Date.new(1980, 1, 1),
            prison_number: 'G3239GV',
            criminal_records_office: 'CRO0111d',
            police_national_computer: 'AB/1234567',
            gender_additional_information: 'info about Bob',
          },
          relationships: {
            ethnicity: {
              data: {
                id: ethnicity_id,
                type: 'ethnicities',
              },
            },
            gender: {
              data: {
                id: gender_id,
                type: 'genders',
              },
            },
          },
        },
      }
    end

    let(:expected_data) do
      {
        type: 'people',
        attributes: {
          first_names: 'Bob',
          last_name: 'Roberts',
          date_of_birth: Date.new(1980, 1, 1).iso8601,
          prison_number: 'G3239GV',
          criminal_records_office: 'CRO0111d',
          police_national_computer: 'AB/1234567',
          gender_additional_information: 'info about Bob',
        },
        relationships: {
          gender: {
            data: {
              type: 'genders',
              id: gender_id,
            },
          },
          ethnicity: {
            data: {
              type: 'ethnicities',
              id: ethnicity_id,
            },
          },
        },
      }
    end

    let(:expected_included) do
      []
    end

    it 'returns the correct data' do
      post '/api/people', params: person_params, headers:, as: :json

      expect(response_json).to include_json(data: expected_data.merge(id: Person.last.id))
    end

    context 'with valid params' do
      before { post '/api/people', params: person_params, headers:, as: :json }

      it_behaves_like 'an endpoint that responds with success 201'
    end

    describe 'include query param' do
      before do
        post "/api/people#{query_params}", params: person_params, headers:, as: :json
      end

      context 'when including multiple relationships' do
        let(:query_params) { '?include=gender,ethnicity' }

        it 'includes the correct relationships' do
          expect(response_json['included'].count).to eq(2)
          expect(response_json['included']).to include_json(UnorderedArray({ type: 'ethnicities' }, { type: 'genders' }))
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
        post '/api/people', params: person_params, headers:, as: :json
      }.to change(Person, :count).by(1)
    end

    describe 'webhook and email notifications' do
      # TODO: verify if the to trigger prepare_notifications even in V2
      # and consider that this implementation does not validate any Person's attributes for now (explicitly required)
      before do
        allow(Notifier).to receive(:prepare_notifications)
        post '/api/people', params: person_params, headers:, as: :json
      end

      it 'does NOT call the notifier when creating a person' do
        expect(Notifier).not_to have_received(:prepare_notifications)
      end
    end

    context 'when a relationship entity is not found' do
      let(:ethnicity_id) { 999 }
      let(:detail_404) { "Couldn't find Ethnicity with 'id'=999" }

      before { post '/api/people#', params: person_params, headers:, as: :json }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with a bad request' do
      before { post '/api/people', params: {}, headers:, as: :json }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with an invalid api version header' do
      let(:headers_with_wrong_version) { headers.merge('Accept': 'application/vnd.api+json; version=9') }

      before { post '/api/people', params: person_params, headers: headers_with_wrong_version, as: :json }

      it 'returns 415 errors message' do
        expect(response).to have_http_status(:unsupported_media_type)
        expect(response_json).to include_json(errors: [
          {
            'title' => 'Invalid Api Version',
            'detail' => 'The Api versions supported are: ["1", "2"]',
          },
        ])
      end
    end
  end
end
