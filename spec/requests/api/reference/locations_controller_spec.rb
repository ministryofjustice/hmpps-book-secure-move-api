# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Reference::LocationsController do
  let(:response_json) { JSON.parse(response.body) }
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:headers) { { 'CONTENT_TYPE': content_type } }
  let(:schema) { load_yaml_schema('get_locations_responses.yaml') }

  describe 'GET /api/v1/reference/locations' do
    let(:supplier) { create(:supplier) }

    let(:params) { {} }

    it_behaves_like 'an endpoint that responds with success 200' do
      before do
        create(
          :location,
          key: 'guildford_crown_court',
          title: 'Guildford Crown Court',
          location_type: 'court',
          nomis_agency_id: 'GCC',
          can_upload_documents: false,
          suppliers: [supplier],
        )
        create(
          :location,
          key: 'hmp_pentonville',
          title: 'HMP Pentonville',
          location_type: 'prison',
          nomis_agency_id: 'PEI',
          can_upload_documents: true,
          suppliers: [supplier],
        )

        get '/api/v1/reference/locations', params:, headers:
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
        }
      end

      it 'returns the correct data' do
        expect(response_json).to include_json(expected_document)
      end
    end

    describe 'still works when authenticated' do
      it_behaves_like 'an endpoint that responds with success 200' do
        before do
          get '/api/v1/reference/locations', params:, headers: headers.merge('Authorization' => "Bearer #{access_token}")
        end
      end
    end

    describe 'included relationships' do
      before do
        create(:location, suppliers: create_list(:supplier, 1))

        get "/api/v1/reference/locations#{query_params}", headers:
      end

      context 'when not including the include query param' do
        let(:query_params) { '' }

        it 'returns the default includes' do
          expect(response_json['included']).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:query_params) { '?include=suppliers' }

        it 'returns the valid provided includes' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('suppliers')
        end
      end

      context 'when including an invalid include query param' do
        let(:query_params) { '?include=foo.bar,suppliers' }

        let(:expected_error) do
          {
            'errors' => [
              {
                'title' => 'Bad request',
                'detail' => '["foo.bar"] is not supported. Valid values are: ["suppliers"]',
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
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end
    end

    describe 'pagination' do
      let(:meta_pagination) do
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
        }
      end
      let(:pagination_links) do
        {
          self: 'http://www.example.com/api/v1/reference/locations?page=1&per_page=5',
          first: 'http://www.example.com/api/v1/reference/locations?page=1&per_page=5',
          prev: nil,
          next: 'http://www.example.com/api/v1/reference/locations?page=2&per_page=5',
          last: 'http://www.example.com/api/v1/reference/locations?page=2&per_page=5',
        }
      end

      before do
        create_list :location, 4
        create_list :location, 2, :court

        get '/api/v1/reference/locations', params:, headers:
      end

      it_behaves_like 'an endpoint that paginates resources'
    end

    describe 'filters' do
      let!(:supplier) { create :supplier }
      let!(:location) { create :location, suppliers: [supplier] }
      let(:created_at) { Date.new(2020, 5, 6) }

      let(:filters) do
        {
          location_type: 'prison',
          nomis_agency_id: 'PEI',
          supplier_id: supplier.id,
          young_offender_institution: nil,
          created_at:,
          extradition_capable: false,
        }
      end

      let(:params) { { filter: filters } }

      before do
        locations_finder = instance_double(Locations::Finder, call: Location.all)
        allow(Locations::Finder).to receive(:new).and_return(locations_finder)

        get '/api/v1/reference/locations', params:, headers:
      end

      it 'delegates the query execution to Locations::Finder with the correct filters' do
        expect(Locations::Finder).to have_received(:new).with(
          filter_params: {
            location_type: location.location_type,
            nomis_agency_id: location.nomis_agency_id,
            supplier_id: supplier.id,
            young_offender_institution: nil,
            created_at: created_at.to_s,
            extradition_capable: false,
          },
          active_record_relationships: nil,
        )
      end

      it 'returns results from Locations::Finder' do
        expect(response_json).to include_json(data: [{ id: location.id }])
      end
    end

    context 'with an extradition_capable location' do
      before do
        create(
          :location,
          key: 'heathrow_custody_suite',
          title: 'Heathrow Custody Suite',
          location_type: 'police',
          nomis_agency_id: 'HCS',
          can_upload_documents: false,
          suppliers: [supplier],
          extradition_capable: true,
        )
      end

      it_behaves_like 'an endpoint that responds with success 200' do
        before do
          get '/api/v1/reference/locations', params:, headers:
        end

        let(:expected_document) do
          {
            data: [
              {
                type: 'locations',
                attributes: {
                  key: 'heathrow_custody_suite',
                  title: 'Heathrow Custody Suite',
                  location_type: 'police',
                  nomis_agency_id: 'HCS',
                  can_upload_documents: false,
                  extradition_capable: true,
                },
              },
            ],
          }
        end

        it 'returns the correct data' do
          expect(response_json).to include_json(expected_document)
        end
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
          young_offender_institution: false,
        },
      }
    end

    let!(:location) { Location.create!(data[:attributes]) }
    let(:location_id) { location.id }

    context 'when successful' do
      before { get "/api/v1/reference/locations/#{location_id}", params:, headers: }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data:)
      end
    end

    context 'when resource is not found' do
      let(:location_id) { 'UUID-not-found' }
      let(:detail_404) { "Couldn't find Location with 'id'=UUID-not-found" }

      before { get "/api/v1/reference/locations/#{location_id}", params:, headers: }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
