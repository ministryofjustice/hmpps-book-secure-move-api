# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Api::JourneysController do
  describe 'GET /moves/:move_id/journeys' do
    include_context 'with supplier with spoofed access token'

    let(:response_json) { JSON.parse(response.body) }
    let(:locations) { create_list(:location, 2, suppliers: [supplier]) }
    let!(:move) { create(:move, from_location: locations.first, to_location: locations.last, supplier: supplier) }
    let!(:last_journey) { create(:journey, move: move, supplier: supplier, client_timestamp: '2020-05-04T09:00:00Z') }
    let!(:intermediate_journeys) { create_list(:journey, intermediate_journeys_count, move: move, supplier: supplier, client_timestamp: '2020-05-04T08:30:00Z') }
    let!(:first_journey) { create(:journey, move: move, supplier: supplier, client_timestamp: '2020-05-04T08:00:00Z') }
    let!(:other_move_journey) { create(:journey, supplier: supplier) } # another journey for a different move, same supplier
    let!(:other_supplier_journey) { create(:journey, move: move) } # another journey for a different supplier, same move

    let(:intermediate_journeys_count) { 1 }
    let(:page) { 1 }
    let(:per_page) { 5 }
    let(:url) { "/api/v1/moves/#{move.id}/journeys" }
    let(:params) { {} }

    before do
      get url, params: params, headers: headers
    end

    context 'when successful' do
      let(:application) { create(:application, owner: supplier) }
      let(:access_token) { create(:access_token, application: application).token }
      let(:schema) { load_yaml_schema('get_journeys_responses.yaml') }

      it_behaves_like 'an endpoint that responds with success 200'

      describe 'response_json' do
        subject(:journey_ids) { response_json['data'].map { |x| x['id'] } }

        it { expect(journey_ids.size).to be 3 }
        it { expect(journey_ids.first).to eql(first_journey.id) } # NB: first_journey should come before last_journey
        it { expect(journey_ids.last).to eql(last_journey.id) }
        it { is_expected.not_to include(other_move_journey.id) } # NB: should not contain another move's journey
        it { is_expected.not_to include(other_supplier_journey.id) } # NB: should not contain another supplier's journey in the same move
      end

      describe 'with included locations' do
        let(:params) do
          { include: 'from_location,to_location' }
        end

        it 'includes the requested includes in the response' do
          returned_types = response_json['included'].map { |r| r['type'] }.uniq
          expect(returned_types).to contain_exactly('locations')
        end
      end

      describe 'paginating results' do
        let(:intermediate_journeys_count) { 4 }
        let(:meta_pagination) do
          {
            per_page: 5,
            total_pages: 2,
            total_objects: 6,
          }
        end
        let(:pagination_links) do
          {
            self: "http://www.example.com/api/v1/moves/#{move.id}/journeys?page=1&per_page=5",
            first: "http://www.example.com/api/v1/moves/#{move.id}/journeys?page=1&per_page=5",
            prev: nil,
            next: "http://www.example.com/api/v1/moves/#{move.id}/journeys?page=2&per_page=5",
            last: "http://www.example.com/api/v1/moves/#{move.id}/journeys?page=2&per_page=5",
          }
        end

        it_behaves_like 'an endpoint that paginates resources'
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
