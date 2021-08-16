# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PopulationsController do
  include_context 'with supplier with spoofed access token'

  let(:response_json) { JSON.parse(response.body) }
  let(:resource_to_json) { JSON.parse(PopulationSerializer.new(population).serializable_hash.to_json) }

  describe 'POST /populations' do
    subject(:post_populations) { post '/api/populations', params: { data: data }, headers: headers, as: :json }

    let(:schema) { load_yaml_schema('post_populations_responses.yaml') }

    let(:population_date) { Time.zone.today }
    let(:population_attributes) do
      {
        date: population_date,
        operational_capacity: 200,
        usable_capacity: 195,
        unlock: 180,
        bedwatch: 3,
        overnights_in: 6,
        overnights_out: 2,
        out_of_area_courts: 1,
        discharges: 7,
        updated_by: 'Fulton McKay',
      }
    end

    let!(:location) { create :location, :prison }

    let(:data) do
      {
        type: 'populations',
        attributes: population_attributes,
        relationships: {
          location: { data: { type: 'locations', id: location.id } },
        },
      }
    end

    context 'when successful' do
      before { post_populations }

      it_behaves_like 'an endpoint that responds with success 201'
    end

    describe 'creating populations' do
      let(:population) { Population.find_by(location_id: location.id) }

      it 'creates a population' do
        expect { post_populations }.to change(Population, :count).by(1)
      end

      it 'returns the correct data' do
        post_populations
        expect(response_json).to include_json resource_to_json
      end
    end

    context 'with a bad request' do
      let(:data) { nil }

      before { post_populations }

      it_behaves_like 'an endpoint that responds with error 400'
    end

    context 'with a reference to a missing relationship' do
      let(:location) { Location.new }
      let(:detail_404) { "Couldn't find Location without an ID" }

      before { post_populations }

      it_behaves_like 'an endpoint that responds with error 404'
    end

    context 'with validation errors' do
      let(:population_attributes) { attributes_for(:population).except(:date) }

      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => "Date can't be blank",
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'blank',
          },
        ]
      end

      before { post_populations }

      it_behaves_like 'an endpoint that responds with error 422'
    end

    context 'when a population record already exists for same date and location' do
      let(:errors_422) do
        [
          {
            'title' => 'Unprocessable entity',
            'detail' => 'Date has already been taken',
            'source' => { 'pointer' => '/data/attributes/date' },
            'code' => 'taken',
          },
        ]
      end

      before do
        create(:population, date: population_date, location: location)
        post_populations
      end

      it_behaves_like 'an endpoint that responds with error 422'
    end
  end
end
