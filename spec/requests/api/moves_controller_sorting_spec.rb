# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::MovesController do
  let(:access_token) { 'spoofed-token' }
  let(:content_type) { ApiController::CONTENT_TYPE }
  let(:response_json) { JSON.parse(response.body) }
  let(:schema) { load_yaml_schema('get_moves_responses.yaml') }

  let(:headers) do
    {
      'Content-Type' => content_type,
      'Authorization' => "Bearer #{access_token}",
      'Idempotency-Key' => SecureRandom.uuid,
    }
  end

  describe 'GET /moves' do
    # NB sorting should be case-sensitive, i.e. LOCATION1, LOCATION3, location2, location4
    let(:location1) { create :location, title: 'LOCATION1' }
    let(:location2) { create :location, title: 'location2' }
    let(:location3) { create :location, title: 'LOCATION3' }
    let(:location4) { create :location, title: 'location4' }

    let(:profile1) { create :profile, person: create(:person, last_name: 'PROFILE1') }
    let(:profile2) { create :profile, person: create(:person, last_name: 'profile2') }
    let(:profile3) { create :profile, person: create(:person, last_name: 'PROFILE3') }
    let(:profile4) { create :profile, person: create(:person, last_name: 'profile4') }

    let!(:move2) { create :move, :prison_transfer, profile: profile2, to_location: location2 }
    let!(:move3) { create :move, :prison_transfer, profile: profile3, to_location: location3 }

    before do
      next if RSpec.current_example.metadata[:skip_before]

      create :move, profile: profile1, to_location: location1
      create :move, profile: profile4, to_location: location4

      get '/api/v1/moves', headers:, params: { sort: sort_params }
    end

    describe 'sorting' do
      describe 'errors' do
        context 'with invalid sort' do
          let(:sort_params) { { by: 'rabbits' } }

          it_behaves_like 'an endpoint that responds with error 422' do
            let(:errors_422) do
              [{ 'title' => 'Invalid sort_by',
                 'detail' => 'Validation failed: Sort by is not included in the list' }]
            end
          end
        end

        context 'with invalid direction' do
          let(:sort_params) { { by: 'created_at', direction: 'rabbits' } }

          it_behaves_like 'an endpoint that responds with error 422' do
            let(:errors_422) do
              [{ 'title' => 'Invalid sort_direction',
                 'detail' => 'Validation failed: Sort direction is not included in the list' }]
            end
          end
        end

        context 'with only direction' do
          let(:sort_params) { { direction: 'asc' } }

          it_behaves_like 'an endpoint that responds with error 422' do
            let(:errors_422) do
              [{ 'title' => 'Invalid sort_by',
                 'detail' => "Validation failed: Sort by can't be blank" }]
            end
          end
        end
      end

      context 'with attributes' do
        let(:move_ids) { response_json['data'].map { |move| move.fetch('id') } }

        context 'without explicit sort' do
          let(:expected) { Move.all.sort_by(&:date).reverse }

          it 'sorts by move date descending', :skip_before do
            get('/api/v1/moves', headers:)

            expect(move_ids).to eq(expected.map(&:id))
          end
        end

        context 'when created_at' do
          context 'when default' do
            let(:sort_params) { { by: 'created_at' } }
            let(:expected) { Move.all.sort_by(&:created_at) }

            it 'sorts by created_at' do
              expect(move_ids).to eq(expected.map(&:id))
            end
          end

          context 'when reversed' do
            let(:sort_params) { { by: 'created_at', direction: 'desc' } }
            let(:expected) { Move.all.sort_by(&:created_at).reverse }

            it 'sorts by created_at' do
              expect(move_ids).to eq(expected.map(&:id))
            end
          end
        end

        context 'when date' do
          let(:move_data) { Move.all.sort_by(&:date) }

          context 'when default' do
            let(:sort_params) { { by: 'date' } }

            it 'sorts by date' do
              expect(move_ids).to eq(move_data.map(&:id))
            end
          end

          context 'when reversed' do
            let(:sort_params) { { by: 'date', direction: 'desc' } }

            it 'sorts by date' do
              expect(move_ids).to eq(move_data.reverse.map(&:id))
            end
          end
        end

        context 'when date_from' do
          let(:move_data) { Move.all.sort_by(&:date_from) }

          context 'when default' do
            let(:sort_params) { { by: 'date_from' } }

            it 'sorts by date_from' do
              expect(move_ids).to eq(move_data.map(&:id))
            end
          end

          context 'when reversed' do
            let(:sort_params) { { by: 'date_from', direction: 'desc' } }

            it 'sorts by date_from' do
              expect(move_ids).to eq(move_data.reverse.map(&:id))
            end
          end
        end
      end

      context 'with nested objects' do
        let(:object_ids) { response_json['data'].map { |move| move.dig('relationships', object_name, 'data', 'id') } }

        context 'when from_location' do
          let(:object_name) { 'from_location' }
          let(:locations) { object_ids.map { |p_id| Location.find(p_id) } }

          context 'with default direction' do
            let(:sort_params) { { by: 'from_location' } }
            let(:expected) do
              Move.all.sort_by { |move| move.from_location.title }.map(&:from_location)
            end

            it 'sorts by from location' do
              expect(locations.map(&:title)).to eq(expected.map(&:title))
            end
          end

          context 'with reverse direction' do
            let(:sort_params) { { by: 'from_location', direction: 'desc' } }
            let(:expected) do
              Move.all.sort_by { |move| move.from_location.title }.reverse.map(&:from_location)
            end

            it 'sorts by from location' do
              expect(locations.map(&:title)).to eq(expected.map(&:title))
            end
          end
        end

        context 'when to_location' do
          let(:locations) { object_ids.map { |p_id| Location.find(p_id) } }
          let(:object_name) { 'to_location' }
          let(:move_data) { Move.all.sort_by { |move| move.to_location.title }.map(&:to_location) }

          context 'with default direction' do
            let(:sort_params) { { by: 'to_location' } }

            it 'sorts by to location' do
              expect(locations.map(&:title)).to match_array(%w[LOCATION1 location2 LOCATION3 location4])
            end
          end

          context 'with reverse direction' do
            let(:sort_params) { { by: 'to_location', direction: 'desc' } }

            it 'sorts by to location' do
              expect(locations.map(&:title)).to match_array(%w[location4 LOCATION3 location2 LOCATION1])
            end
          end
        end

        context 'when name' do
          let(:object_name) { 'person' }
          let(:move_data) do
            Move.all
              .sort_by { |move| move.person.last_name }
              .map(&:person)
          end
          let(:last_names) { object_ids.map { |person_id| Person.find(person_id).last_name } }

          context 'with default direction' do
            let(:sort_params) { { by: 'name' } }

            it 'sorts by last_name (ascending, case sensitive)' do
              expect(last_names).to match_array(%w[PROFILE1 profile2 PROFILE3 profile4])
            end
          end

          context 'with reverse direction' do
            let(:sort_params) { { by: 'name', direction: 'desc' } }

            it 'sorts by last_name' do
              expect(last_names).to match_array(%w[profile4 PROFILE3 profile2 PROFILE1])
            end
          end
        end

        context 'with prison_transfer_reason' do
          let(:sort_params) { { by: 'prison_transfer_reason', direction: 'desc' } }
          let(:object_name) { 'prison_transfer_reason' }

          let(:reasons) { object_ids.map { |p_id| p_id.nil? ? '' : PrisonTransferReason.find(p_id).title } }
          let(:expected) do
            ['', ''] + [move2, move3].map { |move| move.prison_transfer_reason.title }.sort.reverse
          end

          it 'sorts by prison_transfer_reason' do
            expect(reasons).to eq(expected)
          end
        end
      end
    end
  end
end
