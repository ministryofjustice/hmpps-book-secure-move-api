# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MovesController, with_client_authentication: true do
  let(:headers) { { 'CONTENT_TYPE': content_type }.merge(auth_headers) }
  let(:content_type) { ApiController::JSON_API_CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /moves' do
    let(:schema) { load_json_schema('get_moves_responses.json') }

    let!(:moves) { create_list :move, 21 }
    let(:params) { {} }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      get '/api/v1/moves', headers: headers, params: params
    end

    context 'when successful' do
      it_behaves_like 'an endpoint that responds with success 200'

      describe 'filtering results' do
        let(:from_location_id) { moves.first.from_location_id }
        let(:filters) do
          {
            bar: 'bar',
            from_location_id: from_location_id,
            foo: 'foo'
          }
        end
        let(:params) { { filter: filters } }

        it 'delegates the query execution to Moves::Finder with the correct filters', skip_before: true do
          moves_finder = instance_double('Moves::Finder', call: Move.all)
          allow(Moves::Finder).to receive(:new).and_return(moves_finder)

          get '/api/v1/moves', headers: headers, params: params

          expect(Moves::Finder).to have_received(:new).with(from_location_id: from_location_id)
        end

        it 'filters the results' do
          expect(response_json['data'].size).to be 1
        end

        it 'returns the move that matches the filter' do
          expect(response_json).to include_json(data: [{ id: moves.first.id }])
        end
      end

      context 'with a cancelled move' do
        let(:move) { create(:move, :cancelled) }
        let!(:moves) { [move] }
        let(:from_location_id) { move.from_location_id }
        let(:filters) do
          {
            from_location_id: from_location_id
          }
        end
        let(:params) { { filter: filters } }

        # rubocop:disable RSpec/ExampleLength
        it 'returns the correct attributes values for moves' do
          expect(response_json).to include_json(
            data: [
              {
                id: move.id,
                attributes: {
                  cancellation_reason: move.cancellation_reason,
                  cancellation_reason_comment: move.cancellation_reason_comment
                }
              }
            ]
          )
        end
        # rubocop:enable RSpec/ExampleLength
      end

      describe 'paginating results' do
        let(:meta_pagination) do
          {
            per_page: 20,
            total_pages: 2,
            total_objects: 21,
            links: {
              first: '/api/v1/moves?page=1',
              last: '/api/v1/moves?page=2',
              next: '/api/v1/moves?page=2'
            }
          }
        end

        it 'paginates 20 results per page' do
          expect(response_json['data'].size).to eq 20
        end

        it 'returns 1 result on the second page', skip_before: true do
          get '/api/v1/moves?page=2', headers: headers

          expect(response_json['data'].size).to eq 1
        end

        it 'allows setting a different page size', skip_before: true do
          get '/api/v1/moves?per_page=15', headers: headers

          expect(response_json['data'].size).to eq 15
        end

        it 'provides meta data with pagination' do
          expect(response_json['meta']['pagination']).to include_json(meta_pagination)
        end
      end

      describe 'importing moves from NOMIS passing all required filters (NOMIS agency_id and date)' do
        let(:from_location) { moves.first.from_location }
        let(:date) { Date.today }
        let(:filters) do
          {
            from_location_id: from_location.id,
            date_from: date.to_s
          }
        end
        let(:params) { { filter: filters } }

        before do
          allow(NomisClient::Moves).to receive(:get).and_return([])

          moves_importer = instance_double('Moves::Importer', call: [])
          allow(Moves::Importer).to receive(:new).and_return(moves_importer)

          get '/api/v1/moves', headers: headers, params: params
        end

        it 'invokes the client library to fetch moves from NOMIS', skip_before: true do
          expect(NomisClient::Moves).to have_received(:get).with(from_location.nomis_agency_id, date)
        end

        it 'invokes the service to create moves into the database', skip_before: true do
          expect(Moves::Importer).to have_received(:new).with([])
        end
      end

      describe 'not importing moves from NOMIS when missing filters' do
        let(:from_location) { moves.first.from_location }
        let(:filters) do
          {
            from_location_id: from_location.id
          }
        end
        let(:params) { { filter: filters } }

        before do
          allow(NomisClient::Moves).to receive(:get).and_return([])

          moves_importer = instance_double('Moves::Importer', call: [])
          allow(Moves::Importer).to receive(:new).and_return(moves_importer)

          get '/api/v1/moves', headers: headers, params: params
        end

        it 'does not invoke the client library to fetch moves from NOMIS', skip_before: true do
          expect(NomisClient::Moves).not_to have_received(:get)
        end

        it 'does not invoke the service to create moves into the database', skip_before: true do
          expect(Moves::Importer).not_to have_received(:new)
        end
      end

      describe 'not importing moves from NOMIS when an error occurs in NOMIS' do
        let(:from_location) { moves.first.from_location }
        let(:date) { Date.today }
        let(:filters) do
          {
            from_location_id: from_location.id,
            date_from: date.to_s
          }
        end
        let(:params) { { filter: filters } }

        before do
          allow(NomisClient::Moves).to receive(:get).and_raise(StandardError)
          allow(Raven).to receive(:capture_exception)

          moves_finder = instance_double('Moves::Finder', call: Move.all)
          allow(Moves::Finder).to receive(:new).and_return(moves_finder)

          get '/api/v1/moves', headers: headers, params: params
        end

        it 'invokes the Moves::Finder service', skip_before: true do
          expect(Moves::Finder).to have_received(:new)
        end

        it 'calls Raven to log the exception', skip_before: true do
          expect(Raven).to have_received(:capture_exception)
        end
      end
    end

    context 'when not authorized', with_invalid_auth_headers: true do
      it_behaves_like 'an endpoint that responds with error 401'
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:content_type) { 'application/xml' }

      it_behaves_like 'an endpoint that responds with error 415'
    end
  end
end
