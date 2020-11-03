# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PeopleController do
  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:schema) { load_yaml_schema('get_person_responses.yaml', version: 'v2') }
  let(:query_params) { '' }
  let(:params) { {} }

  let(:person) { create(:person, profiles: profiles) }
  let(:profiles) { create_list(:profile, 2, category: category) }
  let(:category) { create(:category) }

  let(:resource_to_json) do
    JSON.parse(V2::PersonSerializer.new(person).serializable_hash.to_json)
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /people/:id' do
    before do
      get "/api/people/#{person.id}#{query_params}", params: params, headers: headers
    end

    it 'returns serialized data' do
      expect(response_json).to eq resource_to_json
    end

    it_behaves_like 'an endpoint that responds with success 200'

    describe 'included relationships' do
      context 'when not including the include query param' do
        it 'returns the default includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:query_params) { '?include=profiles' }

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('profiles')
        end
      end

      context 'when including an invalid include query param' do
        let(:query_params) { '?include=foo.bar,profiles' }

        let(:expected_error) do
          {
            'errors' => [
              {
                'detail' => match(/foo.bar/),
                'title' => 'Bad request',
              },
            ],
          }
        end

        it 'returns a validation error' do
          expect(response).to have_http_status(:bad_request)
          expect(response_json).to include(expected_error)
        end
      end
    end
  end
end
