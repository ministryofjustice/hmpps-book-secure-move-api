# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::JourneysController do
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /moves/:move_id/journeys' do
    let!(:supplier) { create(:supplier) }
    let(:application) { create(:application, owner: supplier) }
    let(:access_token) { create(:access_token, application: application).token }
    let(:headers) { { 'CONTENT_TYPE': content_type, 'Authorization': "Bearer #{access_token}" } }
    let(:content_type) { ApiController::CONTENT_TYPE }

    let(:locations) { create_list(:location, 2, suppliers: [supplier]) }
    let!(:move) { create(:move, from_location: locations.first, to_location: locations.last) }
    let!(:last_journey) { create(:journey, move: move, supplier: supplier, client_timestamp: '2020-05-04T09:00:00Z') }
    let!(:intermediate_journeys) { create_list(:journey, intermediate_journeys_count, move: move, supplier: supplier, client_timestamp: '2020-05-04T08:30:00Z') }
    let!(:first_journey) { create(:journey, move: move, supplier: supplier, client_timestamp: '2020-05-04T08:00:00Z') }
    let!(:other_move_journey) { create(:journey, supplier: supplier) } # another journey for a different move, same supplier
    let!(:other_supplier_journey) { create(:journey, move: move) } # another journey for a different supplier, same move

    let(:intermediate_journeys_count) { 1 }
    let(:page) { 1 }
    let(:per_page) { 5 }
    let(:url) { "/api/v1/moves/#{move.id}/journeys" }

    before do
      get url, headers: headers, as: :json
    end

    context 'when successful' do
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

      describe 'paginating results' do
        let(:url) { "/api/v1/moves/#{move.id}/journeys?page=#{page}&per_page=#{per_page}" }
        let(:intermediate_journeys_count) { 4 }

        describe 'page size' do
          subject { response_json['data'].size }

          context 'when page=1' do
            let(:page) { 1 }

            it { is_expected.to be(5) }
          end

          context 'when page=2' do
            let(:page) { 2 }

            it { is_expected.to be(1) }
          end

          context 'when per_page=15' do
            let(:per_page) { 1 }

            it { is_expected.to be(1) }
          end
        end

        it 'provides meta data with pagination' do
          expect(response_json['meta']['pagination']).to include_json(
            per_page: 5,
            total_pages: 2,
            total_objects: 6,
            links: {
              first: "/api/v1/moves/#{move.id}/journeys?page=1&per_page=#{per_page}",
              last: "/api/v1/moves/#{move.id}/journeys?page=2&per_page=#{per_page}",
              next: "/api/v1/moves/#{move.id}/journeys?page=2&per_page=#{per_page}",
            },
          )
        end
      end
    end

    context 'when unsuccessful' do
      let(:schema) { load_yaml_schema('error_responses.yaml') }

      context 'when not authorized' do
        let(:access_token) { 'foo-bar' }
        let(:detail_401) { 'Token expired or invalid' }

        it_behaves_like 'an endpoint that responds with error 401'
      end

      context 'with an invalid CONTENT_TYPE header' do
        let(:content_type) { 'application/xml' }

        it_behaves_like 'an endpoint that responds with error 415'
      end
    end
  end
end
