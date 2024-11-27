# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  subject(:post_moves_csv) { post '/api/moves/csv', params:, headers:, as: :json }

  let(:supplier) { create(:supplier) }
  let(:access_token) { 'spoofed-token' }
  let(:headers) do
    {
      'CONTENT_TYPE': ApiController::CONTENT_TYPE,
      'Accept': 'text/csv',
      'Authorization' => "Bearer #{access_token}",
    }
  end

  let(:params) { {} }

  describe 'POST /moves/csv' do
    let!(:moves) { create_list :move, 2 }

    it 'returns a success code' do
      post_moves_csv
      expect(response).to have_http_status(:ok)
    end

    it 'returns an inline file response' do
      post_moves_csv
      expect(response.headers['Content-Disposition']).to match('inline')
    end

    it 'sets the correct content type header' do
      post_moves_csv
      expect(response.headers['Content-Type']).to eq('text/csv')
    end

    describe 'filtering results' do
      let(:from_location_id) { moves.first.from_location_id }
      let(:filters) do
        {
          bar: 'bar',
          from_location_id:,
          foo: 'foo',
        }
      end
      let(:params) { { filter: filters } }

      it 'delegates the query execution to Moves::Finder with the correct filters' do
        ability = instance_double(Ability)
        allow(Ability).to receive(:new).and_return(ability)

        moves_finder = instance_double(Moves::Finder, call: Move.all)
        allow(Moves::Finder).to receive(:new).and_return(moves_finder)

        post_moves_csv

        expect(Moves::Finder).to have_received(:new).with(
          filter_params: { from_location_id: },
          ability:,
          order_params: {},
          active_record_relationships: [:from_location, :to_location, :journeys, :profile, :supplier, { person: %i[gender ethnicity] }],
        )
      end
    end

    it 'delegates the CSV generation to Moves::Exporter with the correct moves' do
      moves_exporter = instance_double(Moves::Exporter, call: Tempfile.new)
      allow(Moves::Exporter).to receive(:new).and_return(moves_exporter)

      post_moves_csv

      expect(Moves::Exporter).to have_received(:new).with(ActiveRecord::Relation)
    end
  end
end
