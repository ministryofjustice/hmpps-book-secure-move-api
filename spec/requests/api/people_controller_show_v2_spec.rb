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

  let(:person) { create(:person, profiles:, latest_nomis_booking_id:) }
  let(:profiles) { create_list(:profile, 2) }
  let(:category) { create(:category) }
  let(:latest_nomis_booking_id) { nil }

  let(:resource_to_json) do
    JSON.parse(V2::PersonWithCategorySerializer.new(person).serializable_hash.to_json)
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
      allow(NomisClient::BookingDetails).to receive(:get).with(123).and_return({ category: category.title, category_code: category.key })
      allow(NomisClient::BookingDetails).to receive(:get).with(456).and_return({})
      get "/api/people/#{person.id}#{query_params}", params:, headers:
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

      context 'when including the category relationship' do
        let(:query_params) { '?include=category' }

        context 'when the category exists in Nomis' do
          let(:latest_nomis_booking_id) { 123 }

          it 'includes the requested includes in the response' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('categories')

            returned_titles = response_json['included'].map { |r| r['attributes']['title'] }
            expect(returned_titles).to contain_exactly(category.title)
          end
        end

        context 'when the category does not exist in Nomis' do
          let(:latest_nomis_booking_id) { 456 }

          it 'requested includes is empty' do
            expect(response_json['included']).to be_empty
          end
        end
      end

      context 'with a NOMIS error' do
        let(:query_params) { '?include=category' }
        let(:latest_nomis_booking_id) { 123 }

        before do
          oauth2_response = instance_double('OAuth2::Response', body: '{"error":"server_error","error_description":"Internal Server Error"}', parsed: {}, status: '')
          allow(NomisClient::BookingDetails).to receive(:get).and_raise(OAuth2::Error, oauth2_response)
          get "/api/people/#{person.id}#{query_params}", params:, headers:
        end

        it_behaves_like 'an endpoint that responds with error 502'
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
