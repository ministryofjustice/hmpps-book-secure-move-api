# frozen_string_literal: true

RSpec.describe Api::V1::Reference::LocationsController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/reference/locations' do
    let(:schema) { load_json_schema('get_locations_responses.json') }

    let(:params) { {} }

    context 'when successful' do
      let(:data) do
        [
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
        ]
      end

      before do
        data.each { |location| Location.create!(location[:attributes]) }

        get '/api/v1/reference/locations', headers: headers, params: params
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      let(:detail_401) { 'Token expired or invalid' }

      before { get '/api/v1/reference/locations', headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      before { get '/api/v1/reference/locations', headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 415'
    end

    describe 'pagination' do
      let!(:prisons) { create_list :location, 11 }
      let!(:courts) { create_list :location, 10, :court }
      let(:meta_pagination) do
        {
          per_page: 20,
          total_pages: 2,
          total_objects: 21,
          links: {
            first: '/api/v1/reference/locations?page=1',
            last: '/api/v1/reference/locations?page=2',
            next: '/api/v1/reference/locations?page=2',
          },
        }
      end

      before { get '/api/v1/reference/locations', headers: headers, params: params }

      context 'with no pagination parameters' do
        it 'paginates 20 results per page' do
          expect(response_json['data'].size).to eq 20
        end

        it 'provides meta data with pagination' do
          expect(response_json['meta']['pagination']).to include_json(meta_pagination)
        end
      end

      context 'with page parameter' do
        let(:params) { { page: 2 } }

        it 'returns 1 result on the second page' do
          expect(response_json['data'].size).to eq 1
        end
      end

      context 'with per_page parameter' do
        let(:params) { { per_page: 15 } }

        it 'allows setting a different page size' do
          expect(response_json['data'].size).to eq 15
        end
      end
    end

    describe 'filters' do
      let!(:supplier) { create :supplier }
      let!(:location) { create :location, suppliers: [supplier] }
      let(:filters) { { location_type: 'prison', nomis_agency_id: 'PEI', supplier_id: supplier.id } }
      let(:params) { { filter: filters } }

      before do
        locations_finder = instance_double('Locations::Finder', call: Location.all)
        allow(Locations::Finder).to receive(:new).and_return(locations_finder)

        get '/api/v1/reference/locations', headers: headers, params: params
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
    let(:schema) { load_json_schema('get_location_responses.json') }
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
      before { get "/api/v1/reference/locations/#{location_id}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data: data)
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
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

      before { get "/api/v1/reference/locations/#{location_id}", headers: headers, params: params }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
