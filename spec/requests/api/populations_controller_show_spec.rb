# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PopulationsController do
  include_context 'with supplier with spoofed access token'

  subject(:get_population) do
    get "/api/populations/#{population_id}", params: params, headers: headers
  end

  let(:response_json) { JSON.parse(response.body) }
  let(:params) { {} }

  describe 'GET /populations/:id' do
    let(:population) { create(:population) }
    let(:population_id) { population.id }

    context 'when successful' do
      let(:schema) { load_yaml_schema('get_population_responses.yaml') }
      let(:data) { JSON.parse(PopulationSerializer.new(population).serializable_hash.to_json) }

      before { get_population }

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data)
      end
    end

    describe 'included relationships' do
      context 'when not including the include query param' do
        before { get_population }

        it 'returns the default includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:params) { { include: 'location,moves_from,moves_to' } }

        before do
          create(:move, :prison_transfer, date: population.date, from_location: population.location)
          create(:move, :prison_transfer, date: population.date, to_location: population.location)
          get_population
        end

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }
          expect(returned_types).to contain_exactly('locations', 'moves', 'moves')
        end
      end

      context 'when including an invalid include query param' do
        let(:params) { { include: 'foo.bar,location' } }

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

        before { get_population }

        it 'returns a validation error' do
          expect(response).to have_http_status(:bad_request)
          expect(response_json).to include(expected_error)
        end
      end
    end

    context 'when not found' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }
      let(:population_id) { 'foo' }
      let(:detail_404) { "Couldn't find Population with 'id'=#{population_id}" }

      before { get_population }

      it_behaves_like 'an endpoint that responds with error 404'
    end
  end
end
