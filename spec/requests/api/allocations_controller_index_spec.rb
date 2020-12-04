# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AllocationsController do
  let(:access_token) { 'spoofed-token' }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }

  describe 'GET /allocations' do
    subject(:get_allocations) { get '/api/v1/allocations', params: params, headers: headers }

    let(:schema) { load_yaml_schema('get_allocations_responses.yaml') }
    let(:params) { {} }

    context 'when successful' do
      before { get_allocations }

      it_behaves_like 'an endpoint that responds with success 200'
    end

    describe 'meta data' do
      let!(:allocation) { create(:allocation, :with_moves) }
      let(:expected_json) do
        {
          data: [
            {
              'id': allocation.id,
              'type': 'allocations',
              'meta': {
                'moves': {
                  'total': 1,
                  'filled': 1,
                  'unfilled': 0,
                },
              },
            },
          ],
        }
      end

      it 'includes total and filled moves count' do
        get_allocations
        expect(response_json).to include_json(expected_json)
      end
    end

    describe 'finding results' do
      before do
        allocations_finder = instance_double('Allocations::Finder', call: Allocation.all)
        allow(Allocations::Finder).to receive(:new).and_return(allocations_finder)
      end

      context 'with filters' do
        let(:allocation) { create :allocation }
        let(:location) { allocation.from_location }
        let(:date_from) { allocation.date }
        let(:filters) do
          {
            bar: 'bar',
            date_from: date_from.to_s,
            from_locations: location.id,
            status: 'unfilled',
            foo: 'foo',
          }
        end
        let(:params) { { filter: filters } }

        it 'delegates the query execution to Allocations::Finder with the correct filters' do
          get_allocations

          expect(Allocations::Finder).to have_received(:new).with(
            filters: { date_from: date_from.to_s, from_locations: location.id, status: 'unfilled' },
            ordering: {},
            search: {},
            active_record_relationships: nil,
          )
        end
      end

      context 'with sorting' do
        let(:sort) do
          {
            bar: 'bar',
            by: 'moves_count',
            direction: 'desc',
            foo: 'foo',
          }
        end
        let(:params) { { sort: sort } }

        it 'delegates the query execution to Allocations::Finder with the correct sorting' do
          get_allocations

          expect(Allocations::Finder).to have_received(:new).with(
            filters: {},
            ordering: { by: 'moves_count', direction: 'desc' },
            search: {},
            active_record_relationships: nil,
          )
        end
      end

      context 'with search' do
        let(:search) do
          {
            bar: 'bar',
            location: 'nott',
            foo: 'foo',
          }
        end
        let(:params) { { search: search } }

        it 'delegates the query execution to Allocations::Finder with the correct sorting' do
          get_allocations

          expect(Allocations::Finder).to have_received(:new).with(
            filters: {},
            ordering: {},
            search: { location: 'nott' },
            active_record_relationships: nil,
          )
        end
      end
    end

    describe 'paginating results' do
      let!(:allocations) { create_list :allocation, 6 }
      let(:meta_pagination) do
        {
          per_page: 5,
          total_pages: 2,
          total_objects: 6,
        }
      end
      let(:pagination_links) do
        {
          self: 'http://www.example.com/api/v1/allocations?page=1&per_page=5',
          first: 'http://www.example.com/api/v1/allocations?page=1&per_page=5',
          prev: nil,
          next: 'http://www.example.com/api/v1/allocations?page=2&per_page=5',
          last: 'http://www.example.com/api/v1/allocations?page=2&per_page=5',
        }
      end

      before { get_allocations }

      it_behaves_like 'an endpoint that paginates resources'
    end

    describe 'validating dates before running queries' do
      let(:filters) do
        {
          date_from: 'yyyy-09-Tu',
        }
      end
      let(:params) { { filter: filters } }

      before { get_allocations }

      it 'is a bad request' do
        expect(response.status).to eq(400)
      end

      it 'returns errors' do
        expect(response.body).to eq('{"error":{"date_from":["is not a valid date."]}}')
      end
    end

    describe 'validating locations before running queries' do
      let(:filters) do
        {
          from_locations: 'foo',
          to_locations: 'bar',
          locations: 'baz',
        }
      end
      let(:params) { { filter: filters } }

      before { get_allocations }

      it 'is a bad request' do
        expect(response.status).to eq(400)
      end

      it 'returns errors' do
        expect(response.body).to eq('{"error":{"locations":["may not be used in combination with `from_locations` or `to_locations` filters."]}}')
      end
    end

    describe 'included relationships' do
      let!(:allocation) { create :allocation, :with_moves }

      before { get_allocations }

      context 'when not including the include query param' do
        let!(:allocation) { create(:allocation, :with_moves) }
        let(:params) { {} }

        it 'returns no included relationships ' do
          expect(response_json).not_to include('included')
        end
      end

      context 'when including the include param' do
        let(:params) { { include: 'from_location' } }

        it 'returns the valid provided includes' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('locations')
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
  end
end
