# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Reference::LocationsController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }
  let(:params) { {} }

  describe 'GET /api/v1/reference/locations' do
    let(:schema) { load_json_schema('get_locations_responses.json') }
    let(:response_json) { JSON.parse(response.body) }

    context 'with the correct CONTENT_TYPE header' do
      let(:data) do
        [
          {
            type: 'locations',
            attributes: {
              description: 'Guildford Crown Court',
              location_type: 'court',
              location_code: 'GCC'
            }
          },
          {
            type: 'locations',
            attributes: {
              description: 'HMP Pentonville',
              location_type: 'prison',
              location_code: 'PEI'
            }
          }
        ]
      end

      before do
        data.map do |location|
          Location.create!(location[:attributes])
        end

        get '/api/v1/reference/locations', headers: headers, params: params
      end

      it 'returns a success code' do
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        expect(JSON.parse(response.body)).to include_json(data: data)
      end

      it 'sets the correct content type header' do
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      before { get '/api/v1/reference/locations', headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it 'fails if I set the wrong `content-type` header' do
        get '/api/v1/reference/locations', headers: headers, params: params
        expect(response.code).to eql '415'
      end
    end

    describe 'pagination' do
      let!(:prisons) { create_list :location, 11 }
      let!(:courts) { create_list :location, 10, :court }
      let(:location_id) { prisons.first.id }
      let(:meta_pagination) do
        {
          per_page: 20,
          total_pages: 2,
          total_objects: 21,
          links: {
            first: '/api/v1/reference/locations?page=1',
            last: '/api/v1/reference/locations?page=2',
            next: '/api/v1/reference/locations?page=2'
          }
        }
      end

      before { get '/api/v1/reference/locations', headers: headers, params: params }

      context 'with no pagination parameters' do
        it 'paginates 20 results per page' do
          expect(JSON.parse(response.body)['data'].size).to eq 20
        end

        it 'provides meta data with pagination' do
          expect(JSON.parse(response.body)['meta']['pagination']).to include_json(meta_pagination)
        end
      end

      context 'with page parameter' do
        let(:params) { { page: 2 } }

        it 'returns 1 result on the second page' do
          expect(JSON.parse(response.body)['data'].size).to eq 1
        end
      end

      context 'with per_page parameter' do
        let(:params) { { per_page: 15 } }

        it 'allows setting a different page size' do
          expect(JSON.parse(response.body)['data'].size).to eq 15
        end
      end
    end

    describe 'filters' do
      let!(:location) { create :location }
      let(:filters) { { location_type: 'prison' } }
      let(:location_finder) { double }
      let(:params) { { filter: filters } }

      before do
        allow(location_finder).to receive(:call).and_return(Location.all)
        allow(Locations::Finder).to receive(:new).and_return(location_finder)

        get '/api/v1/reference/locations', headers: headers, params: params
      end

      it 'delegates the query execution to Locations::Finder with the correct filters' do
        expect(Locations::Finder).to have_received(:new).with(location_type: location.location_type)
      end

      it 'returns results from Locations::Finder' do
        expect(JSON.parse(response.body)).to include_json(data: [{ id: location.id }])
      end
    end

    describe 'response schema validation', with_json_schema: true do
      before { get '/api/v1/reference/locations', headers: headers, params: params }

      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:content_type) { 'application/xml' }

        it 'returns a valid 415 JSON response' do
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
        end
      end
    end
  end
end
