# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  let(:response_json) { JSON.parse(response.body) }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:schema) { load_yaml_schema('get_move_responses.yaml', version: 'v2') }
  let(:params) { {} }

  let(:resource_to_json) do
    JSON.parse(V2::MoveSerializer.new(move).serializable_hash.to_json)
  end

  let(:headers) do
    {
      'CONTENT_TYPE': content_type,
      'Accept': 'application/vnd.api+json; version=2',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  describe 'GET /moves/:id' do
    let!(:move) { create(:move) }

    it 'returns serialized data' do
      do_get
      expect(response_json).to eq resource_to_json
    end

    it_behaves_like 'an endpoint that responds with success 200' do
      before { do_get }
    end

    describe 'included relationships' do
      let!(:move) do
        create(
          :move,
          profile: profile,
          from_location: from_location,
          to_location: to_location,
          court_hearings: [court_hearing],
        )
      end

      let(:profile) { create(:profile) }
      let(:court_hearing) { create(:court_hearing) }
      let(:to_location) { create(:location, suppliers: [supplier]) }
      let(:from_location) { create(:location, suppliers: [supplier]) }

      before do
        get "/api/moves#{query_params}", params: params, headers: headers
      end

      context 'when not including the include query param' do
        let(:query_params) { '' }

        it 'returns the default includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:query_params) { '?include=profile' }

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('profiles')
        end
      end

      context 'when including an invalid include query param' do
        let(:query_params) { '?include=foo.bar,profile' }

        let(:expected_error) do
          {
            'errors' => [
              {
                'detail' => match(/foo.bar/),
                'title' => 'Bad request',
              },
            ],
          }
        end

        it 'returns a validation error' do
          expect(response).to have_http_status(:bad_request)
          expect(response_json).to include(expected_error)
        end
      end
    end
  end

  def do_get
    get "/api/moves/#{move.id}", params: params, headers: headers
  end
end
