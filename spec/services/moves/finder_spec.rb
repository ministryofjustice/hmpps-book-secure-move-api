# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Finder do
  subject(:results) do
    described_class.new(
      filter_params: filter_params,
      ability: ability,
      order_params: order_params,
      active_record_relationships: active_record_relationships,
    ).call
  end

  let(:filter_params) { {} }
  let(:application) { Doorkeeper::Application.new(name: 'test') }
  let(:ability) { Ability.new(application) }
  let(:order_params) { {} }
  let(:active_record_relationships) { [] }

  describe 'filtering' do
    context 'with no filters' do
      let(:move) { create :move, :prison_recall }
      let!(:proposed_move) { create :move, :proposed }
      let!(:cancelled_supplier_declined_to_move) { create :move, :cancelled_supplier_declined_to_move }
      let!(:completed_move) { create :move, :completed }
      let!(:move_with_allocation) { create(:move, :with_allocation) }
      let!(:move_with_person_escort_record) { create(:move, :with_person_escort_record) }
      let(:filter_params) { {} }

      it 'returns all moves' do
        expect(results).to match_array [move, proposed_move, cancelled_supplier_declined_to_move, completed_move, move_with_allocation, move_with_person_escort_record]
      end
    end

    describe 'by location_id' do
      let!(:shared_location) { create :location }
      let!(:move) { create :move, from_location: shared_location }
      let!(:second_move) { create :move, to_location: shared_location }

      context 'with matching location filter' do
        let(:filter_params) { { location_id: shared_location.id } }

        it 'returns moves matching from location or to location' do
          expect(results).to contain_exactly(move, second_move)
        end
      end

      context 'with two location filters' do
        let!(:third_move) { create :move }
        let(:filter_params) { { location_id: [shared_location.id, third_move.from_location_id] } }

        it 'returns moves matching multiple locations' do
          expect(results).to contain_exactly(move, second_move, third_move)
        end
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { location_id: Random.uuid } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by from_location_id' do
      let!(:move) { create :move }

      context 'with matching location filter' do
        let(:filter_params) { { from_location_id: [move.from_location_id] } }

        it 'returns moves matching from location' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with two location filters' do
        let!(:second_move) { create :from_prison_to_court }
        let(:filter_params) { { from_location_id: [move.from_location_id, second_move.from_location_id] } }

        it 'returns moves matching multiple locations' do
          expect(results).to contain_exactly(move, second_move)
        end
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { from_location_id: Random.uuid } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by to_location_id' do
      let!(:move) { create :move }

      context 'with matching location filter' do
        let(:filter_params) { { to_location_id: [move.to_location_id] } }

        it 'returns moves matching from location' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with two location filters' do
        let!(:second_move) { create :from_prison_to_court }
        let(:filter_params) { { to_location_id: [move.to_location_id, second_move.to_location_id] } }

        it 'returns moves matching multiple locations' do
          expect(results).to contain_exactly(move, second_move)
        end
      end

      context 'with empty location filter' do
        let!(:second_move) { create(:move, :video_remand) }
        let(:filter_params) { { to_location_id: [] } }

        it 'returns moves matching empty location' do
          expect(results).to contain_exactly(second_move)
        end
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { to_location_id: Random.uuid } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by location_type' do
      let!(:move) { create :move }

      context 'with matching location type' do
        let(:filter_params) { { location_type: move.to_location.location_type } }

        it 'returns moves matching location type' do
          expect(results).to match_array [move]
        end
      end

      context 'with mis-matching location type' do
        let(:filter_params) { { location_type: 'hospital' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by supplier_id' do
      context 'with supplier filter' do
        let(:move) { create :move }
        let(:filter_params) { { supplier_id: move.supplier_id } }

        it 'returns moves matching the supplier' do
          create :move, from_location: move.from_location

          expect(results).to contain_exactly move
        end
      end
    end

    describe 'by dates' do
      let!(:move) { create :move }

      context 'with matching date range' do
        let!(:move_5_days_future) { create(:move, date: move.date + 5.days) }
        let(:filter_params) { { date_from: move.date.to_s, date_to: (move.date + 5.days).to_s } }

        before do
          create(:move, date: move.date + 6.days)
          create(:move, date: move.date - 1.day)
        end

        it 'returns moves matching date range' do
          expect(results).to match_array [move, move_5_days_future]
        end
      end

      context 'with mis-matching date range in past' do
        let(:filter_params) { { date_from: (move.date - 5.days).to_s, date_to: (move.date - 2.days).to_s } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end

      context 'with mis-matching date range in future' do
        let(:filter_params) { { date_from: (move.date + 2.days).to_s, date_to: (move.date + 5.days).to_s } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by date of birth' do
      let(:date_of_birth) { 18.years.ago }
      let!(:person) { create :person, date_of_birth: date_of_birth }
      let!(:profile) { create :profile, person: person }
      let!(:move) { create :move, profile: profile }

      context 'with matching date range' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth - 2.days).to_s, date_of_birth_to: (date_of_birth + 1.day).to_s } }

        it 'returns moves matching date of birth range' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with matching exact date' do
        let(:filter_params) { { date_of_birth_from: date_of_birth.to_s, date_of_birth_to: date_of_birth.to_s } }

        it 'returns moves matching date of birth range' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with matching date of birth from only' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth - 1.day).to_s } }

        it 'returns moves matching date of birth range' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with matching date of birth to only' do
        let(:filter_params) { { date_of_birth_to: (date_of_birth + 1.day).to_s } }

        it 'returns moves matching date of birth range' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with mis-matching date of birth range in past' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth - 5.days).to_s, date_of_birth_to: (date_of_birth - 3.days).to_s } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end

      context 'with mis-matching date of birth range in future' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth + 2.days).to_s, date_of_birth_to: (date_of_birth + 5.days).to_s } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end

      context 'with nil values' do
        let(:filter_params) { { date_of_birth_from: nil, date_of_birth_to: nil } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by move status' do
      let!(:proposed_move) { create :move, :proposed }
      let!(:requested_move) { create :move, :requested }
      let!(:booked_move) { create :move, :booked }
      let!(:in_transit_move) { create :move, :in_transit }
      let!(:completed_move) { create :move, :completed }

      before { create :move, :cancelled }

      context 'with matching status' do
        let(:filter_params) { { status: 'proposed' } }

        it 'returns moves matching status' do
          expect(results).to match_array [proposed_move]
        end
      end

      context 'with multiple statuses' do
        let(:filter_params) { { status: 'requested,completed,booked,in_transit' } }

        it 'returns moves matching status' do
          expect(results).to match_array [requested_move, completed_move, booked_move, in_transit_move]
        end
      end

      context 'with mis-matching status' do
        let(:filter_params) { { status: 'fruit bats' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by move_type' do
      let!(:court_appearance_move) { create :move, :court_appearance }
      let!(:prison_recall_move) { create :move, :prison_recall }
      let!(:prison_transfer_move) { create :move, :prison_transfer }
      let!(:police_transfer_move) { create :move, :police_transfer }

      context 'with matching move_type' do
        let(:filter_params) { { move_type: 'court_appearance' } }

        it 'returns moves matching type' do
          expect(results).to match_array [court_appearance_move]
        end
      end

      context 'with multiple move_types' do
        let(:filter_params) { { move_type: 'prison_transfer,prison_recall,police_transfer' } }

        it 'returns moves matching status' do
          expect(results).to match_array [prison_recall_move, prison_transfer_move, police_transfer_move]
        end
      end

      context 'with mis-matching move_type' do
        let(:filter_params) { { move_type: 'fruit bats' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by cancellation_reason' do
      let!(:cancelled_made_in_error_move) { create :move, :cancelled_made_in_error }
      let!(:cancelled_rejected_move) { create :move, :cancelled_rejected }
      let!(:cancelled_other_move) { create :move, :cancelled_other }

      before { create :move, :cancelled_supplier_declined_to_move }

      context 'with nil cancellation reason' do
        let(:filter_params) { { cancellation_reason: nil } }

        it 'returns only moves without a cancellation reason' do
          expect(results).to be_empty
        end
      end

      context 'with empty cancellation reason' do
        let(:filter_params) { { cancellation_reason: '' } }
        let!(:prison_recall_move) { create :move, :prison_recall }

        it 'returns only moves without a cancellation reason' do
          expect(results).to contain_exactly(prison_recall_move)
        end
      end

      context 'with matching cancellation_reason' do
        let(:filter_params) { { cancellation_reason: 'other' } }

        it 'returns moves matching type' do
          expect(results).to match_array [cancelled_other_move]
        end
      end

      context 'with multiple cancellation_reasons' do
        let(:filter_params) { { cancellation_reason: 'made_in_error,rejected' } }

        it 'returns moves matching status' do
          expect(results).to match_array [cancelled_made_in_error_move, cancelled_rejected_move]
        end
      end

      context 'with mis-matching cancellation_reason' do
        let(:filter_params) { { cancellation_reason: 'fruit bats' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by rejection_reason' do
      let!(:rejected_no_space) { create :move, :rejected_no_space }
      let!(:rejected_no_transport) { create :move, :rejected_no_transport }

      context 'with nil rejection reason' do
        let(:filter_params) { { rejection_reason: nil } }

        it 'returns only moves without a rejection reason' do
          expect(results).to be_empty
        end
      end

      context 'with empty rejection reason' do
        let(:filter_params) { { rejection_reason: '' } }
        let!(:prison_recall_move) { create :move, :prison_recall }

        it 'returns only moves without a rejection reason' do
          expect(results).to contain_exactly(prison_recall_move)
        end
      end

      context 'with matching rejection' do
        let(:filter_params) { { rejection_reason: 'no_space_at_receiving_prison' } }

        it 'returns moves matching type' do
          expect(results).to match_array [rejected_no_space]
        end
      end

      context 'with multiple rejection' do
        let(:filter_params) { { rejection_reason: 'no_space_at_receiving_prison,no_transport_available' } }

        it 'returns moves matching status' do
          expect(results).to match_array [rejected_no_space, rejected_no_transport]
        end
      end

      context 'with mis-matching rejection' do
        let(:filter_params) { { rejection_reason: 'arm stuck in a packet of cornflakes' } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by has_relationship_to_allocation' do
      let!(:move_with_allocation) { create(:move, :with_allocation) }
      let!(:move_without_allocation) { create(:move) }

      context 'with wrong type passed to has_relationship_to_allocation filter' do
        let(:filter_params) { { has_relationship_to_allocation: Random.uuid } }

        it 'returns all moves' do
          expect(results).to contain_exactly(move_with_allocation, move_without_allocation)
        end
      end

      context 'with has_relationship_to_allocation set as `nil`' do
        let(:filter_params) { { has_relationship_to_allocation: nil } }

        it 'returns all moves' do
          expect(results).to contain_exactly(move_with_allocation, move_without_allocation)
        end
      end

      context 'with has_relationship_to_allocation set as `false`' do
        let(:filter_params) { { has_relationship_to_allocation: 'false' } }

        it 'returns only moves without allocations' do
          expect(results).to contain_exactly(move_without_allocation)
        end
      end

      context 'with has_relationship_to_allocation set as `true`' do
        let(:filter_params) { { has_relationship_to_allocation: 'true' } }

        it 'returns only moves with allocations' do
          expect(results).to contain_exactly(move_with_allocation)
        end
      end
    end

    describe 'by ready_for_transit' do
      let!(:move_with_no_person_escort_record) { create(:move) }
      let!(:move_with_unstarted_person_escort_record) { create(:move, :with_person_escort_record) }
      let!(:move_with_in_progress_person_escort_record) do
        create(:move, :with_person_escort_record, person_escort_record_status: 'in_progress')
      end
      let!(:move_with_completed_person_escort_record) do
        create(:move, :with_person_escort_record, person_escort_record_status: 'completed')
      end
      let!(:move_with_confirmed_person_escort_record) do
        create(:move, :with_person_escort_record, person_escort_record_status: 'confirmed')
      end
      let(:active_record_relationships) { [profile: [:person_escort_record]] }

      context 'with ready_for_transit set as `true`' do
        let(:filter_params) { { ready_for_transit: 'true' } }

        it 'returns completed and confirmed moves' do
          expect(results).to contain_exactly(
            move_with_completed_person_escort_record,
            move_with_confirmed_person_escort_record,
          )
        end
      end

      context 'with ready_for_transit set as `false`' do
        let(:filter_params) { { ready_for_transit: 'false' } }

        it 'returns all non completed or confirmed moves' do
          expect(results).to contain_exactly(
            move_with_no_person_escort_record,
            move_with_unstarted_person_escort_record,
            move_with_in_progress_person_escort_record,
          )
        end
      end

      context 'with ready_for_transit set as `nil`' do
        let(:filter_params) { { ready_for_transit: nil } }

        it 'returns all moves' do
          expect(results).to contain_exactly(
            move_with_no_person_escort_record,
            move_with_unstarted_person_escort_record,
            move_with_in_progress_person_escort_record,
            move_with_completed_person_escort_record,
            move_with_confirmed_person_escort_record,
          )
        end
      end

      context 'with ready_for_transit set as empty string' do
        let(:filter_params) { { ready_for_transit: '' } }

        it 'returns all moves' do
          expect(results).to contain_exactly(
            move_with_no_person_escort_record,
            move_with_unstarted_person_escort_record,
            move_with_in_progress_person_escort_record,
            move_with_completed_person_escort_record,
            move_with_confirmed_person_escort_record,
          )
        end
      end
    end

    describe 'sort order' do
      let(:location1) { create :location, title: 'LOCATION1' }
      let(:order_params) { { by: :to_location, direction: :asc } }
      let(:location2) { create :location, title: 'Location2' }
      let(:location3) { create :location, title: 'LOCATION3' }

      before do
        create :move, to_location: location1
        create :move, to_location: location2
        create :move, to_location: location3
      end

      it 'ordered by location (case-sensitive)' do
        expect(results.map(&:to_location).pluck(:title)).to eql(%w[LOCATION1 LOCATION3 Location2]) # NB: case-sensitive order
      end
    end

    describe 'by profile_id' do
      let(:profile) { create :profile }
      let!(:move) { create :move, profile: profile }

      context 'with matching profile filter' do
        let(:filter_params) { { profile_id: profile.id } }

        it 'returns moves matching the profile' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with two profile filters' do
        let(:second_move) { create :move }
        let(:filter_params) { { profile_id: [profile.id, second_move.profile_id] } }

        it 'returns moves matching multiple locations' do
          expect(results).to contain_exactly(move, second_move)
        end
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { profile_id: Random.uuid } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by person_id' do
      let(:person) { create :person }
      let!(:move) { create :move, person: person }

      context 'with matching profile filter' do
        let(:filter_params) { { person_id: person.id } }

        it 'returns moves matching the profile' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with two profile filters' do
        let(:second_move) { create :move }
        let(:filter_params) { { person_id: [person.id, second_move.person_id] } }

        it 'returns moves matching multiple locations' do
          expect(results).to contain_exactly(move, second_move)
        end
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { person_id: Random.uuid } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end

    describe 'by reference' do
      let(:reference) { SecureRandom.uuid }
      let!(:move) { create :move, reference: reference }

      context 'with matching profile filter' do
        let(:filter_params) { { reference: reference } }

        it 'returns moves matching the profile' do
          expect(results).to contain_exactly(move)
        end
      end

      context 'with two profile filters' do
        let(:second_move) { create :move }
        let(:filter_params) { { reference: [reference, second_move.reference] } }

        it 'returns moves matching multiple locations' do
          expect(results).to contain_exactly(move, second_move)
        end
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { reference: Random.uuid } }

        it 'returns empty results set' do
          expect(results).to be_empty
        end
      end
    end
  end
end
