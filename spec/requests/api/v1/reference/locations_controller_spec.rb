# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Reference::LocationsController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { create(:access_token).token }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:schema) { load_yaml_schema('get_locations_responses.yaml') }

  describe 'GET /api/v1/reference/locations' do
    let(:supplier) { create(:supplier) }

    let(:params) { {} }

    context 'when successful' do
      let!(:locations) do
        [
          create(
            :location,
            key: 'guildford_crown_court',
            title: 'Guildford Crown Court',
            location_type: 'court',
            nomis_agency_id: 'GCC',
            can_upload_documents: false,
            suppliers: [supplier],
          ),
          create(
            :location,
            key: 'hmp_pentonville',
            title: 'HMP Pentonville',
            location_type: 'prison',
            nomis_agency_id: 'PEI',
            can_upload_documents: true,
            suppliers: [supplier],
          ),
        ]
      end
      let(:expected_document) do
        {
          data: [
            {
              type: 'locations',
              attributes: {
                key: 'guildford_crown_court',
                title: 'Guildford Crown Court',
                location_type: 'court',
                nomis_agency_id: 'GCC',
                can_upload_documents: false,
              },
            },
            {
              type: 'locations',
              attributes: {
                key: 'hmp_pentonville',
                title: 'HMP Pentonville',
                location_type: 'prison',
                nomis_agency_id: 'PEI',
                can_upload_documents: true,
              },
            },
          ],
          included: [],
        }
      end

      it 'returns the correct data' do
        expect(response_json).to include_json(expected_document)
      end

      context 'when a valid include query is passed' do
        it 'returns the correct data' do
          expect(response_json).to include_json(expected_document)
        end
      end

      it_behaves_like 'an endpoint that responds with success 200' do
        before do
          get '/api/v1/reference/locations', params: params, headers: headers
        end
      end

      describe 'included relationships', :skip_before do
        let!(:allocations) { create_list :allocation, 2, :with_moves }

        before do
          get "/api/v1/allocations#{query_params}", headers: headers
        end

        context 'when not including the include query param' do
          let(:query_params) { '' }

          it 'returns the default includes' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('people', 'moves', 'locations')
          end
        end

        context 'when including the include query param' do
          let(:query_params) { '?include=from_location' }

          it 'returns the valid provided includes' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('locations')
          end
        end

        context 'when including an invalid include query param' do
          let(:query_params) { '?include=foo.bar,from_location' }

          let(:expected_error) do
            {
              'errors' => [
                {
                  'title' => 'Bad request',
                  'detail' => '["foo.bar"] is not supported. Valid values are: ["from_location", "to_location", "moves.person"]',
                },
              ],
            }
          end

          it 'returns a validation error' do
            expect(response).to have_http_status(:bad_request)
            expect(response_json).to eq(expected_error)
          end
        end

        context 'when including an empty include query param' do
          let(:query_params) { '?include=' }

          it 'returns none of the includes' do
            returned_types = response_json['included']
            expect(returned_types).to be_nil
          end
        end

        context 'when including a nil include query param' do
          let(:query_params) { '?include' }

          it 'returns the default includes' do
            returned_types = response_json['included'].map { |r| r['type'] }.uniq
            expect(returned_types).to contain_exactly('people', 'moves', 'locations')
          end
        end
      end
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:detail_401) { 'Token expired or invalid' }
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }

      before { get '/api/v1/reference/locations', headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { get '/api/v1/reference/locations', headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    describe 'pagination' do
      let!(:prisons) { create_list :location, 4 }
      let!(:courts) { create_list :location, 2, :court }
      let(:meta_pagination) do
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
          links: {
            first: '/api/v1/reference/locations?page=1',
            last: '/api/v1/reference/locations?page=2',
            next: '/api/v1/reference/locations?page=2',
          },
        }
      end

      before { get '/api/v1/reference/locations', params: params, headers: headers }

      it_behaves_like 'an endpoint that paginates resources'
    end

    describe 'filters' do
      let!(:supplier) { create :supplier }
      let!(:location) { create :location, suppliers: [supplier] }
      let(:filters) { { location_type: 'prison', nomis_agency_id: 'PEI', supplier_id: supplier.id } }
      let(:params) { { filter: filters } }

      before do
        locations_finder = instance_double('Locations::Finder', call: Location.all)
        allow(Locations::Finder).to receive(:new).and_return(locations_finder)

        get '/api/v1/reference/locations', params: params, headers: headers
      end

      it 'delegates the query execution to Locations::Finder with the correct filters' do
        expect(Locations::Finder).to have_received(:new).with(
          location_type: location.location_type,
          nomis_agency_id: location.nomis_agency_id,
          supplier_id: supplier.id,
        )
      end

      it 'returns results from Locations::Finder' do
        expect(response_json).to include_json(data: [{ id: location.id }])
      end
    end
  end

  describe 'GET /api/v1/reference/locations/:id' do
    let(:schema) { load_yaml_schema('get_location_responses.yaml') }
    let(:params) { {} }
    let(:data) do
      {
        type: 'locations',
        attributes: {
          key: 'hmp_pentonville',
          title: 'HMP Pentonville',
          location_type: 'prison',
          nomis_agency_id: 'PEI',
        },
      }
    end

    let!(:location) { Location.create!(data[:attributes]) }
    let(:location_id) { location.id }

    context 'when successful' do
      before { get "/api/v1/reference/locations/#{location_id}", params: params, headers: headers }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:content_type) { ApiController::CONTENT_TYPE }
      let(:detail_401) { 'Token expired or invalid' }

      before { get "/api/v1/reference/locations/#{location_id}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { get "/api/v1/reference/locations/#{location_id}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    context 'when resource is not found' do
      let(:location_id) { 'UUID-not-found' }
      let(:detail_404) { "Couldn't find Location with 'id'=UUID-not-found" }

      before { get "/api/v1/reference/locations/#{location_id}", params: params, headers: headers }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
