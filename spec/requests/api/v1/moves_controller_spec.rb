# frozen_string_literal: true

require 'rails_helper'
require 'support/with_json_schema_context'

RSpec.describe Api::V1::MovesController do
  let(:headers) { { 'CONTENT_TYPE': ApiController::JSON_API_CONTENT_TYPE } }

  let(:move_to_json) do
    ActionController::Base.render json: move, include: MoveSerializer::INCLUDED_DETAIL
  end

  let(:errors_404) do
    [
      {
        'title' => 'Resource not found',
        'detail' => "Couldn't find Move with 'id'=UUID-not-found"
      }
    ]
  end

  let(:errors_415) do
    [
      {
        'title' => 'Invalid Media Type',
        'detail' => 'Content-Type must be application/vnd.api+json'
      }
    ]
  end

  describe 'GET /moves' do
    context 'when there is no data' do
      context 'with the correct CONTENT_TYPE header' do
        it 'returns a success code' do
          get '/api/v1/moves', headers: headers
          expect(response).to be_successful
        end

        it 'returns an empty list' do
          get '/api/v1/moves', headers: headers
          expect(JSON.parse(response.body)).to include_json(data: [])
        end

        it 'sets the correct content type header' do
          get '/api/v1/moves', headers: headers
          expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
        end
      end
    end

    context 'with move data' do
      let!(:moves) { create_list :move, 21 }
      let(:move_id) { moves.first.id }
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
      let(:data_with_person) do
        [
          {
            id: moves.first.person.id,
            type: 'people'
          }
        ]
      end

      it 'returns a success code' do
        get '/api/v1/moves', headers: headers
        expect(response).to be_successful
      end

      it 'returns a list of moves' do
        get '/api/v1/moves', headers: headers
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end

      it 'paginates 20 results per page' do
        get '/api/v1/moves', headers: headers

        expect(JSON.parse(response.body)['data'].size).to eq 20
      end

      it 'returns 1 result on the second page' do
        get '/api/v1/moves?page=2', headers: headers

        expect(JSON.parse(response.body)['data'].size).to eq 1
      end

      it 'allows setting a different page size' do
        get '/api/v1/moves?per_page=15', headers: headers

        expect(JSON.parse(response.body)['data'].size).to eq 15
      end

      it 'provides meta data with pagination' do
        get '/api/v1/moves', headers: headers

        expect(JSON.parse(response.body)['meta']['pagination']).to include_json(meta_pagination)
      end

      it 'includes an associated Person' do
        get '/api/v1/moves', headers: headers

        # have not included full JSON response - just focusing on people
        expect(JSON.parse(response.body)['included']).to include_json(data_with_person)
      end
    end

    describe 'params' do
      let!(:move) { create :move }
      let(:move_id) { move.id }
      let(:filters) do
        {
          bar: 'bar',
          from_location_id: move.from_location_id,
          foo: 'foo'
        }
      end
      let(:move_finder) { double }

      before do
        allow(move_finder).to receive(:call).and_return(Move.all)
        allow(Moves::Finder).to receive(:new).and_return(move_finder)
      end

      it 'delegates the query execution to Moves::Finder with the correct filters' do
        get '/api/v1/moves', headers: headers, params: { filter: filters }
        expect(Moves::Finder).to have_received(:new).with(from_location_id: move.from_location_id)
      end

      it 'returns results from Moves::Finder' do
        get '/api/v1/moves', headers: headers, params: { filter: filters }
        expect(JSON.parse(response.body)).to include_json(data: [{ id: move_id }])
      end
    end

    context 'when not authorized' do
      it 'returns a not authorized error code' do
        pending 'not implemented yet'
        get '/api/v1/moves', headers: headers
        expect(response).to have_http_status(401)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        get '/api/v1/moves', headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_401)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'returns invalid media type error code' do
        get '/api/v1/moves', headers: headers
        expect(response).to have_http_status(415)
      end

      it 'returns errors in the body of the response' do
        get '/api/v1/moves', headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_415)
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('get_moves_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      before { create :move }

      context 'with the correct CONTENT_TYPE header' do
        it 'returns a valid 200 JSON response with move data' do
          get '/api/v1/moves', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          get '/api/v1/moves', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/415')).to be true
        end
      end
    end
  end

  describe 'GET /moves/{moveId}' do
    let!(:move) { create :move }

    context 'when successful' do
      it 'returns a success code' do
        get "/api/v1/moves/#{move.id}", headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        get "/api/v1/moves/#{move.id}", headers: headers
        expect(JSON.parse(response.body)).to include_json(JSON.parse(move_to_json))
      end

      it 'sets the correct content type header' do
        get "/api/v1/moves/#{move.id}", headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'when not authorized' do
      it 'returns a not authorized error code' do
        pending 'not implemented yet'
        get "/api/v1/moves/#{move.id}", headers: headers
        expect(response).to have_http_status(401)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        get '/api/v1/moves/UUID-not-found', headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_401)
      end
    end

    context 'when resource is not found' do
      it 'returns a resource not found error code' do
        get '/api/v1/moves/UUID-not-found', headers: headers
        expect(response).to have_http_status(404)
      end

      it 'returns errors in the body of the response' do
        get '/api/v1/moves/UUID-not-found', headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_404)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'returns invalid media type error code' do
        get "/api/v1/moves/#{move.id}", headers: headers
        expect(response).to have_http_status(415)
      end

      it 'returns errors in the body of the response' do
        get "/api/v1/moves/#{move.id}", headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_415)
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('get_move_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'when successful' do
        it 'returns a valid 200 JSON response' do
          get "/api/v1/moves/#{move.id}", headers: headers
          expect(JSON::Validator.validate!(schema, response_json, fragment: '#/200')).to be true
        end
      end

      context 'when not authorized' do
        it 'returns a valid 401 JSON response' do
          pending 'not implemented yet'
          get "/api/v1/moves/#{move.id}", headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/401')).to be true
        end
      end

      context 'when resource is not found' do
        it 'returns a valid 404 JSON response' do
          get '/api/v1/moves/UUID-not-found', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/404')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          get "/api/v1/moves/#{move.id}", headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
        end
      end
    end
  end

  describe 'POST /moves' do
    # TODO: define move params
    let(:move_params) { {} }

    context 'when successful' do
      # TODO: define expected_data
      let(:expected_data) { {} }

      it 'returns a success code' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'returns the correct data' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with a bad request' do
      it 'returns bad request error code' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(response).to have_http_status(400)
      end
    end

    context 'when not authorized' do
      it 'returns not authorized error code' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(response).to have_http_status(401)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_401)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'returns a invalid media type error code' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(response).to have_http_status(415)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_415)
      end
    end

    context 'with validation errors' do
      let(:errors) do
        [
          {
            'source' => { 'pointer' => '/data/attributes/from_location' },
            'code' => 'validation_error',
            'detail' => 'must exist'
          },
          {
            'source' => { 'pointer' => '/data/attributes/from_location' },
            'code' => 'validation_error',
            'detail' => 'can\'t be blank'
          }
        ]
      end

      it 'returns unprocessable entity error code' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(response).to have_http_status(422)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        post '/api/v1/moves', params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors)
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('post_moves_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'when successful' do
        it 'returns a valid 201 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/moves', params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/201')).to be true
        end
      end

      context 'with a bad request' do
        it 'returns a valid 400 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/moves', params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/400')).to be true
        end
      end

      context 'when not authorized' do
        it 'returns a valid 401 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/moves', params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/401')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/moves', params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
        end
      end

      context 'with validation errors' do
        it 'returns a valid 422 JSON response' do
          pending 'not implemented yet'
          post '/api/v1/moves', params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/422')).to be true
        end
      end
    end
  end

  describe 'PUT /moves/{moveId}' do
    # TODO: define move params
    let(:move_params) { {} }
    let!(:move) { create :move }

    context 'when successful' do
      # TODO: define expected_data
      let(:expected_data) { {} }

      it 'returns a success code' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'with a bad request' do
      it 'returns bad request error code' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(response).to have_http_status(400)
      end
    end

    context 'when not authorized' do
      it 'returns not authorized error code' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(response).to have_http_status(401)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_401)
      end
    end

    context 'when resource is not found' do
      it 'returns a resource not found error code' do
        pending 'not implemented yet'
        put '/api/v1/moves/UUID-not-found', params: { move: move_params }, headers: headers
        expect(response).to have_http_status(404)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        put '/api/v1/moves/UUID-not-found', params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_404)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'returns a invalid media type error code' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(response).to have_http_status(415)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_415)
      end
    end

    context 'with validation errors' do
      let(:errors) do
        [
          {
            'source' => { 'pointer' => '/data/attributes/from_location' },
            'code' => 'validation_error',
            'detail' => 'must exist'
          },
          {
            'source' => { 'pointer' => '/data/attributes/from_location' },
            'code' => 'validation_error',
            'detail' => 'can\'t be blank'
          }
        ]
      end

      it 'returns unprocessable entity error code' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(response).to have_http_status(422)
      end

      it 'provides errors in the body of the response' do
        pending 'not implemented yet'
        put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors)
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('put_move_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'when successful' do
        it 'returns a valid 200 JSON response' do
          pending 'not implemented yet'
          put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/200')).to be true
        end
      end

      context 'with a bad request' do
        it 'returns a valid 400 JSON response' do
          pending 'not implemented yet'
          put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/400')).to be true
        end
      end

      context 'when not authorized' do
        it 'returns a valid 401 JSON response' do
          pending 'not implemented yet'
          put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/401')).to be true
        end
      end

      context 'when resource is not found' do
        it 'returns a valid 404 JSON response' do
          pending 'not implemented yet'
          put '/api/v1/moves/UUID-not-found', params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/404')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          pending 'not implemented yet'
          put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
        end
      end

      context 'with validation errors' do
        it 'returns a valid 422 JSON response' do
          pending 'not implemented yet'
          put "/api/v1/moves/#{move.id}", params: { move: move_params }, headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/422')).to be true
        end
      end
    end
  end

  describe 'DELETE /moves/{moveId}' do
    let!(:move) { create :move }

    context 'when successful' do
      # TODO: define expected data
      let(:expected_data) { move.to_json }

      it 'returns a success code' do
        pending 'not implemented yet'
        delete "/api/v1/moves/#{move.id}", headers: headers
        expect(response).to be_successful
      end

      it 'returns the correct data' do
        pending 'not implemented yet'
        delete "/api/v1/moves/#{move.id}", headers: headers
        expect(JSON.parse(response.body)).to include_json(data: expected_data)
      end

      it 'sets the correct content type header' do
        pending 'not implemented yet'
        delete "/api/v1/moves/#{move.id}", headers: headers
        expect(response.headers['Content-Type']).to match(Regexp.escape(ApiController::JSON_API_CONTENT_TYPE))
      end
    end

    context 'when not authorized' do
      it 'returns a not authorized error code' do
        pending 'not implemented yet'
        delete "/api/v1/moves/#{move.id}", headers: headers
        expect(response).to have_http_status(401)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        delete "/api/v1/moves/#{move.id}", headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_401)
      end
    end

    context 'when resource is not found' do
      it 'returns a resource not found error code' do
        pending 'not implemented yet'
        delete '/api/v1/moves/UUID-not-found', headers: headers
        expect(response).to have_http_status(404)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        delete '/api/v1/moves/UUID-not-found', headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_404)
      end
    end

    context 'with an invalid CONTENT_TYPE header' do
      let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

      it 'returns invalid media type error code' do
        pending 'not implemented yet'
        delete "/api/v1/moves/#{move.id}", headers: headers
        expect(response).to have_http_status(415)
      end

      it 'returns errors in the body of the response' do
        pending 'not implemented yet'
        delete "/api/v1/moves/#{move.id}", headers: headers
        expect(JSON.parse(response.body)).to include_json(errors: errors_415)
      end
    end

    describe 'response schema validation', with_json_schema: true do
      let(:schema) { load_json_schema('delete_move_responses.json') }
      let(:response_json) { JSON.parse(response.body) }

      context 'when successful' do
        it 'returns a valid 200 JSON response' do
          pending 'not implemented yet'
          delete "/api/v1/moves/#{move.id}", headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/200')).to be true
        end
      end

      context 'when not authorized' do
        it 'returns a valid 401 JSON response' do
          pending 'not implemented yet'
          delete "/api/v1/moves/#{move.id}", headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/401')).to be true
        end
      end

      context 'when resource is not found' do
        it 'returns a valid 404 JSON response' do
          pending 'not implemented yet'
          delete '/api/v1/moves/UUID-not-found', headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/404')).to be true
        end
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:headers) { { 'CONTENT_TYPE': 'application/xml' } }

        it 'returns a valid 415 JSON response' do
          pending 'not implemented yet'
          delete "/api/v1/moves/#{move.id}", headers: headers
          expect(JSON::Validator.validate!(schema, response_json, strict: true, fragment: '#/415')).to be true
        end
      end
    end
  end
end
