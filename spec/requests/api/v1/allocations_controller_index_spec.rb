# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AllocationsController do
  let(:supplier) { create(:supplier) }
  let!(:application) { create(:application, owner_id: supplier.id) }
  let!(:access_token) { create(:access_token, application: application).token }
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge('Authorization' => "Bearer #{access_token}") }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }

  describe 'GET /allocations' do
    let(:schema) { load_yaml_schema('get_allocations_responses.yaml') }

    let!(:allocations) { create_list :allocation, 2 }
    let(:params) { {} }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      get '/api/v1/allocations', params: params, headers: headers
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      describe 'filtering results by date' do
        let(:allocation) { allocations.last }
        let(:date_from) { allocation.date }
        let(:filters) do
          {
            bar: 'bar',
            date_from: date_from.to_s,
            foo: 'foo',
          }
        end
        let(:params) { { filter: filters } }

        it 'delegates the query execution to Allocations::Finder with the correct filters', skip_before: true do
          allocations_finder = instance_double('Allocations::Finder', call: Allocation.all)
          allow(Allocations::Finder).to receive(:new).and_return(allocations_finder)

          get '/api/v1/allocations', headers: headers, params: params

          expect(Allocations::Finder).to have_received(:new).with(date_from: date_from.to_s)
        end

        it 'filters the results' do
          expect(response_json['data'].size).to be 1
        end

        it 'returns the allocation that matches the filter' do
          expect(response_json).to include_json(data: [{ id: allocation.id }])
        end
      end

      describe 'filtering results by location' do
        let(:allocation) { allocations.last }
        let(:location) { allocations.last.from_location }
        let(:params) { { filter: { from_locations: location.id } } }

        it 'filters the results' do
          expect(response_json['data'].size).to be 1
        end

        it 'returns the allocation that matches the filter' do
          expect(response_json).to include_json(data: [{ id: allocation.id }])
        end
      end

      describe 'filtering results by status' do
        let(:unfilled_allocation) { create :allocation, :unfilled }
        let(:filled_allocation) { create :allocation, :filled }
        let(:cancelled_allocation) { create :allocation, :cancelled }
        let!(:allocations) { [unfilled_allocation, filled_allocation, cancelled_allocation] }
        let(:params) { { filter: { status: 'cancelled' } } }

        it 'filters the results' do
          expect(response_json['data'].size).to be 1
        end

        it 'returns the allocation that matches the filter' do
          expect(response_json).to include_json(data: [{ id: cancelled_allocation.id }])
        end
      end

      describe 'paginating results' do
        let!(:allocations) { create_list :allocation, 21 }

        let(:meta_pagination) do
          {
            per_page: 20,
            total_pages: 2,
            total_objects: 21,
            links: {
              first: '/api/v1/allocations?page=1',
              last: '/api/v1/allocations?page=2',
              next: '/api/v1/allocations?page=2',
            },
          }
        end

        it 'paginates 20 results per page' do
          expect(response_json['data'].size).to eq 20
        end

        it 'returns 1 result on the second page', skip_before: true do
          get '/api/v1/allocations?page=2', headers: headers

          expect(response_json['data'].size).to eq 1
        end

        it 'allows setting a different page size', skip_before: true do
          get '/api/v1/allocations?per_page=15', headers: headers

          expect(response_json['data'].size).to eq 15
        end

        it 'provides meta data with pagination', skip_before: true do
          get '/api/v1/allocations', headers: headers

          expect(response_json['meta']['pagination']).to include_json(meta_pagination)
        end
      end

      describe 'validating dates before running queries' do
        let(:filters) do
          {
            date_from: 'yyyy-09-Tu',
          }
        end
        let(:params) { { filter: filters } }

        before do
          get '/api/v1/allocations', params: params, headers: headers
        end

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

        before do
          get '/api/v1/allocations', params: params, headers: headers
        end

        it 'is a bad request' do
          expect(response.status).to eq(400)
        end

        it 'returns errors' do
          expect(response.body).to eq('{"error":{"locations":["may not be used in combination with `from_locations` or `to_locations` filters."]}}')
        end
      end

      describe 'included relationships', :skip_before do
        let!(:allocations) { create_list :allocation, 2, :with_moves }

        before do
          get "/api/v1/allocations#{query_params}", params: params, headers: headers
        end

        context 'when not including the include query param' do
          let(:query_params) { '' }

          let(:included) do
            from_locations = allocations.map(&:from_location)
            to_locations = allocations.map(&:to_location)
            moves = allocations.flat_map(&:moves)
            people = moves.map { |move| move&.profile&.person }

            from_locations + to_locations + moves + people
          end

          it 'returns the default includes' do
            expect(response_json).to have_includes(included)
          end
        end

        context 'when including the include query param' do
          let(:query_params) { '?include=foo.bar,from_location' }

          let(:included) { allocations.map(&:from_location) }

          it 'returns the valid provided includes' do
            expect(response_json).to have_includes(included)
          end
        end

        context 'when including an empty include query param' do
          let(:query_params) { '?include=' }

          let(:included) { [] }

          it 'returns none of the includes' do
            expect(response_json).to have_includes(included)
          end
        end

        context 'when including an empty include query param' do
          let(:query_params) { '?include' }

          let(:included) do
            from_locations = allocations.map(&:from_location)
            to_locations = allocations.map(&:to_location)
            moves = allocations.flat_map(&:moves)
            people = moves.map { |move| move&.profile&.person }

            from_locations + to_locations + moves + people
          end

          it 'returns the default includes' do
            expect(response_json).to have_includes(included)
          end
        end
      end
    end

    context 'when not authorized', :skip_before, :with_invalid_auth_headers do
      let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
      let(:detail_401) { 'Token expired or invalid' }

      before do
        get '/api/v1/allocations', headers: headers
      end

      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
