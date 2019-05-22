# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::Reference::LocationsController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  describe 'GET /api/v1/reference/locations' do
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
      end

      it 'returns a success code' do
        get '/api/v1/reference/locations', headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        get '/api/v1/reference/locations', headers: headers
        expect(JSON.parse(response.body)).to include_json(data: data)
      end

      it 'sets the correct content type header' do
        get '/api/v1/reference/locations', headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'fails if I set the wrong `content-type` header' do
        get '/api/v1/reference/locations', headers: headers
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

      it 'paginates 20 results per page' do
        get '/api/v1/reference/locations', headers: headers

        expect(JSON.parse(response.body)['data'].size).to eq 20
      end

      it 'returns 1 result on the second page' do
        get '/api/v1/reference/locations?page=2', headers: headers

        expect(JSON.parse(response.body)['data'].size).to eq 1
      end

      it 'allows setting a different page size' do
        get '/api/v1/reference/locations?per_page=15', headers: headers

        expect(JSON.parse(response.body)['data'].size).to eq 15
      end

      it 'provides meta data with pagination' do
        get '/api/v1/reference/locations', headers: headers

        expect(JSON.parse(response.body)['meta']['pagination']).to include_json(meta_pagination)
      end
    end

    describe 'filters' do
      let!(:location) { create :location }
      let(:filters) { { location_type: 'prison' } }
      let(:location_finder) { double }

      before do
        allow(location_finder).to receive(:call).and_return(Location.all)
        allow(Locations::Finder).to receive(:new).and_return(location_finder)
      end

      it 'delegates the query execution to Locations::Finder with the correct filters' do
        get '/api/v1/reference/locations', headers: headers, params: { filter: filters }
        expect(Locations::Finder).to have_received(:new).with(location_type: location.location_type)
      end

      it 'returns results from Locations::Finder' do
        get '/api/v1/reference/locations', headers: headers, params: { filter: filters }
        expect(JSON.parse(response.body)).to include_json(data: [{ id: location.id }])
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('get_locations_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          get '/api/v1/reference/locations', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          get '/api/v1/reference/locations', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
        end
      end
    end
  end
end
