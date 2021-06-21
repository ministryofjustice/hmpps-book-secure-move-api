# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PopulationsController do
  subject(:get_new_population) do
    get '/api/populations/new', params: params, headers: headers
  end

  include_context 'with supplier with spoofed access token'

  let(:response_json) { JSON.parse(response.body) }

  let(:location) { create(:location, :prison) }
  let(:location_id) { location.id }
  let(:date) { Date.today.iso8601 }
  let(:params) { { location_id: location_id, date: date } }

  before do
    allow(Populations::DefaultsFromNomis).to receive(:call).and_return({})
  end

  describe 'GET /populations/new' do
    context 'when successful' do
      let(:schema) { load_yaml_schema('get_new_population_responses.yaml') }
      let(:nomis_data) { { unlock: 200, discharges: 20 } }
      let(:data) do
        {
          'data' => {
            'id' => nil,
            'type' => 'populations',
            'attributes' => {
              'date' => date,
              'operational_capacity' => nil,
              'usable_capacity' => nil,
              'bedwatch' => nil,
              'overnights_in' => nil,
              'overnights_out' => nil,
              'out_of_area_courts' => nil,
              'unlock' => 200,
              'discharges' => 20,
              'free_spaces' => nil,
              'updated_by' => nil,
              'created_at' => nil,
              'updated_at' => nil,
            },
            'relationships' => {
              'location' => {
                'data' => {
                  'id' => location.id,
                  'type' => 'locations',
                },
              },
              'moves_from' => {
                'data' => [],
              },
              'moves_to' => {
                'data' => [],
              },
            },
          },
        }
      end

      before do
        allow(Populations::DefaultsFromNomis).to receive(:call) { nomis_data }
        get_new_population
      end

      it_behaves_like 'an endpoint that responds with success 200'

      it 'returns the correct data' do
        expect(response_json).to include_json(data)
      end
    end

    describe 'included relationships' do
      context 'when not including the include query param' do
        before { get_new_population }

        it 'returns the default includes' do
          returned_types = response_json['included']
          expect(returned_types).to be_nil
        end
      end

      context 'when including the include query param' do
        let(:params) { { location_id: location_id, date: date, include: 'location' } }

        before { get_new_population }

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }
          expect(returned_types).to contain_exactly('locations')
        end
      end

      context 'when including an invalid include query param' do
        let(:params) { { location_id: location_id, date: date, include: 'foo.bar,location' } }

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

        before { get_new_population }

        it 'returns a validation error' do
          expect(response).to have_http_status(:bad_request)
          expect(response_json).to include(expected_error)
        end
      end
    end

    context 'when location not found' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }
      let(:location_id) { 'foo' }
      let(:detail_404) { "Couldn't find Location with 'id'=#{location_id}" }

      before { get_new_population }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'when location is omitted' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }
      let(:params) { { date: date } }
      let(:detail_404) { "Couldn't find Location without an ID" }

      before { get_new_population }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'when date is invalid' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }
      let(:date) { 'foo' }
      let(:errors_422) { [{ title: 'Invalid date', detail: 'Date is not a valid date' }] }

      before { get_new_population }

      it_behaves_like 'an endpoint that responds with error 422'
    end

    context 'when date is omitted' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }
      let(:params) { { location_id: location.id } }
      let(:errors_422) { [{ title: 'Invalid date', detail: 'Date is not a valid date' }] }

      before { get_new_population }

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
