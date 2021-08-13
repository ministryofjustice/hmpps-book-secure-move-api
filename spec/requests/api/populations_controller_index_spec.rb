# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PopulationsController do
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }

  describe 'GET /locations_free_spaces' do
    subject(:get_locations_free_spaces) { get '/api/locations_free_spaces', params: params.merge(date_params), headers: headers }

    let(:schema) { load_yaml_schema('get_locations_responses.yaml') }
    let(:params) { {} }
    let(:date_from) { Time.zone.today }
    let(:date_to) { Date.tomorrow }
    let(:date_params) { { date_from: date_from.to_s, date_to: date_to.to_s } }

    context 'when successful' do
      before { get_locations_free_spaces }

      it_behaves_like 'an endpoint that responds with success 200'
    end

    describe 'meta data' do
      let!(:location) { create(:location, :prison) }
      let!(:population) { create(:population, location: location, date: date_from) }
      let(:expected_json) do
        {
          data: [
            {
              "id": location.id,
              "type": 'locations',
              "attributes": {
                "title": location.title,
              },
              "meta": {
                "populations": [
                  {
                    "id": population.id,
                    "free_spaces": population.free_spaces,
                    "transfers_in": 0,
                    "transfers_out": 0,
                  },
                  {
                    "id": nil,
                    "free_spaces": nil,
                    "transfers_in": 0,
                    "transfers_out": 0,
                  },
                ],
              },
            },
          ],
        }
      end

      it 'includes population id and free spaces' do
        get_locations_free_spaces
        expect(response_json).to include_json(expected_json)
      end
    end

    describe 'finding results' do
      before do
        locations_finder = instance_double('Locations::Finder', call: Location.all)
        allow(Locations::Finder).to receive(:new).and_return(locations_finder)
      end

      context 'with filters' do
        let(:location) { create :location, :prison }
        let(:region) { create :region, locations: [location] }
        let(:filters) do
          {
            bar: 'bar',
            region_id: region.id,
            location_id: location.id,
            foo: 'foo',
          }
        end
        let(:params) { { filter: filters } }

        it 'delegates the query execution to Locations::Finder with the correct filters' do
          get_locations_free_spaces
          expect(Locations::Finder).to have_received(:new).with(
            filter_params: { region_id: region.id, location_id: location.id },
            sort_params: {},
            active_record_relationships: nil,
          )
        end
      end

      context 'with sorting' do
        let(:sort) do
          {
            bar: 'bar',
            by: 'title',
            direction: 'desc',
            foo: 'foo',
          }
        end
        let(:params) { { sort: sort } }

        it 'delegates the query execution to Locations::Finder with the correct sorting' do
          get_locations_free_spaces
          expect(Locations::Finder).to have_received(:new).with(
            filter_params: {},
            sort_params: { by: 'title', direction: 'desc' },
            active_record_relationships: nil,
          )
        end
      end
    end

    describe 'included relationships' do
      let!(:category) { create :category }

      before do
        create :location, category: category
        get_locations_free_spaces
      end

      context 'when not including the include query param' do
        let(:params) { {} }

        it 'returns no included relationships ' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including the include param' do
        let(:params) { { include: 'category' } }

        it 'returns the valid provided includes' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('categories')
        end
      end

      context 'when including an empty include param' do
        let(:params) { { include: '' } }

        it 'returns none of the includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end
    end

    describe 'paginating results' do
      let(:meta_pagination) do
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
        }
      end
      let(:pagination_links) do
        {
          self: "http://www.example.com/api/locations_free_spaces?date_from=#{date_from}&date_to=#{date_to}&page=1&per_page=5",
          first: "http://www.example.com/api/locations_free_spaces?date_from=#{date_from}&date_to=#{date_to}&page=1&per_page=5",
          prev: nil,
          next: "http://www.example.com/api/locations_free_spaces?date_from=#{date_from}&date_to=#{date_to}&page=2&per_page=5",
          last: "http://www.example.com/api/locations_free_spaces?date_from=#{date_from}&date_to=#{date_to}&page=2&per_page=5",
        }
      end

      before do
        create_list :location, 6
        get_locations_free_spaces
      end

      it_behaves_like 'an endpoint that paginates resources'
    end

    describe 'validating mandatory date parameters' do
      let(:date_params) { { date_from: date_from } }

      before { get_locations_free_spaces }

      it 'is a bad request' do
        expect(response.status).to eq(422)
      end

      it 'returns errors' do
        expect(response.body).to eq('{"errors":[{"title":"Invalid date_to","detail":"Validation failed: Date to can\'t be blank"}]}')
      end
    end

    describe 'validating dates before running queries' do
      let(:date_params) { { date_from: 'yyyy-09-Tu', date_to: date_to } }

      before { get_locations_free_spaces }

      it 'is a bad request' do
        expect(response.status).to eq(422)
      end

      it 'returns errors' do
        expect(response.body).to eq('{"errors":[{"title":"Invalid date_from","detail":"Validation failed: Date from is not a valid date"}]}')
      end
    end
  end
end
