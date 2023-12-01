# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Moves::Finder do
  subject(:results) do
    described_class.new(
      filter_params:,
      ability:,
      order_params:,
      active_record_relationships:,
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

      it { is_expected.to match_array([move, proposed_move, cancelled_supplier_declined_to_move, completed_move, move_with_allocation, move_with_person_escort_record]) }
    end

    describe 'by location_id' do
      let!(:shared_location) { create :location }
      let!(:move) { create :move, from_location: shared_location }
      let!(:second_move) { create :move, to_location: shared_location }

      context 'with matching location filter' do
        let(:filter_params) { { location_id: shared_location.id } }

        it { is_expected.to contain_exactly(move, second_move) }
      end

      context 'with two location filters' do
        let!(:third_move) { create :move }
        let(:filter_params) { { location_id: [shared_location.id, third_move.from_location_id] } }

        it { is_expected.to contain_exactly(move, second_move, third_move) }
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { location_id: Random.uuid } }

        it { is_expected.to be_empty }
      end

      context 'with a journey on a different day' do
        let(:journey) { create(:journey, move:, date: '2022-01-01') }
        let(:filter_params) { { location_id: [journey.to_location_id] } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with a single active journey, when journey.to_location is different from move.to_location' do
        let(:journey) { create(:journey, move:, date: move.date) }
        let(:filter_params) { { location_id: [journey.to_location_id] } }

        it { expect(move.to_location).not_to eq(journey.to_location) }
        it { is_expected.to contain_exactly(move) }
      end
    end

    describe 'by from_location_id' do
      let!(:move) { create :move }

      context 'with matching location filter' do
        let(:filter_params) { { from_location_id: [move.from_location_id] } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with two location filters' do
        let!(:second_move) { create :from_prison_to_court }
        let(:filter_params) { { from_location_id: [move.from_location_id, second_move.from_location_id] } }

        it { is_expected.to contain_exactly(move, second_move) }
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { from_location_id: Random.uuid } }

        it { is_expected.to be_empty }
      end

      context 'with a journey' do
        let(:journey) { create(:journey, move:, date: '2022-01-01') }
        let(:filter_params) { { from_location_id: [journey.from_location_id] } }

        it { is_expected.to contain_exactly(move) }
      end
    end

    describe 'by to_location_id' do
      let!(:move) { create :move }

      context 'with matching location filter' do
        let(:filter_params) { { to_location_id: [move.to_location_id] } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with two location filters' do
        let!(:second_move) { create :from_prison_to_court }
        let(:filter_params) { { to_location_id: [move.to_location_id, second_move.to_location_id] } }

        it { is_expected.to contain_exactly(move, second_move) }
      end

      context 'with empty location filter' do
        let!(:second_move) { create(:move, :video_remand) }
        let(:filter_params) { { to_location_id: [] } }

        it { is_expected.to contain_exactly(second_move) }
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { to_location_id: Random.uuid } }

        it { is_expected.to be_empty }
      end

      context 'with a journey' do
        let(:journey) { create(:journey, move:, date: '2022-01-01') }
        let(:filter_params) { { to_location_id: [journey.to_location_id] } }

        it { is_expected.to contain_exactly(move) }
      end
    end

    context 'with multi-day moves' do
      let(:move) { create(:move, date: '2022-01-01') }
      let(:middle_location) { create(:location) }

      before do
        create(:journey, move:, date: '2022-01-01', from_location: move.from_location, to_location: middle_location)
        create(:journey, move:, date: '2022-01-02', from_location: middle_location, to_location: move.to_location)
      end

      context 'and day one, outgoing, first location' do
        let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.from_location_id] } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'and day one, outgoing, second location' do
        let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [middle_location] } }

        it { is_expected.to be_empty }
      end

      context 'and day one, outgoing, third location' do
        let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.to_location_id] } }

        it { is_expected.to be_empty }
      end

      context 'and day one, incoming, first location' do
        let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.from_location_id] } }

        it { is_expected.to be_empty }
      end

      context 'and day one, incoming, second location' do
        let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [middle_location] } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'and day one, incoming, third location' do
        let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.to_location_id] } }

        it { is_expected.to be_empty }
      end

      context 'and day two, outgoing, first location' do
        let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.from_location_id] } }

        it { is_expected.to be_empty }
      end

      context 'and day two, outgoing, second location' do
        let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [middle_location] } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'and day two, outgoing, third location' do
        let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.to_location_id] } }

        it { is_expected.to be_empty }
      end

      context 'and day two, incoming, first location' do
        let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.from_location_id] } }

        it { is_expected.to be_empty }
      end

      context 'and day two, incoming, second location' do
        let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [middle_location] } }

        it { is_expected.to be_empty }
      end

      context 'and day two, incoming, third location' do
        let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.to_location_id] } }

        it { is_expected.to contain_exactly(move) }
      end
    end

    describe 'by location_type' do
      let!(:move) { create :move }

      context 'with matching location type' do
        let(:filter_params) { { location_type: move.to_location.location_type } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with mis-matching location type' do
        let(:filter_params) { { location_type: 'hospital' } }

        it { is_expected.to be_empty }
      end
    end

    describe 'by supplier_id' do
      context 'with supplier filter' do
        let(:move) { create :move }
        let(:filter_params) { { supplier_id: move.supplier_id } }

        before { create(:move, from_location: move.from_location) }

        it { is_expected.to contain_exactly(move) }
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

        it { is_expected.to contain_exactly(move, move_5_days_future) }
      end

      context 'with mis-matching date range in past' do
        let(:filter_params) { { date_from: (move.date - 5.days).to_s, date_to: (move.date - 2.days).to_s } }

        it { is_expected.to be_empty }
      end

      context 'with mis-matching date range in future' do
        let(:filter_params) { { date_from: (move.date + 2.days).to_s, date_to: (move.date + 5.days).to_s } }

        it { is_expected.to be_empty }
      end

      context 'with journey dates after move date' do
        before do
          create(:journey, move:, date: move.date + 1.day)
        end

        let(:filter_params) { { date_from: (move.date + 1.day).to_s, date_to: (move.date + 5.days).to_s } }

        it 'returns moves matching date range' do
          expect(results).to match_array [move]
        end
      end
    end

    describe 'by date of birth' do
      let(:date_of_birth) { 18.years.ago }
      let!(:person) { create :person, date_of_birth: }
      let!(:profile) { create :profile, person: }
      let!(:move) { create :move, profile: }

      context 'with matching date range' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth - 2.days).to_s, date_of_birth_to: (date_of_birth + 1.day).to_s } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with matching exact date' do
        let(:filter_params) { { date_of_birth_from: date_of_birth.to_s, date_of_birth_to: date_of_birth.to_s } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with matching date of birth from only' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth - 1.day).to_s } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with matching date of birth to only' do
        let(:filter_params) { { date_of_birth_to: (date_of_birth + 1.day).to_s } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with mis-matching date of birth range in past' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth - 5.days).to_s, date_of_birth_to: (date_of_birth - 3.days).to_s } }

        it { is_expected.to be_empty }
      end

      context 'with mis-matching date of birth range in future' do
        let(:filter_params) { { date_of_birth_from: (date_of_birth + 2.days).to_s, date_of_birth_to: (date_of_birth + 5.days).to_s } }

        it { is_expected.to be_empty }
      end

      context 'with nil values' do
        let(:filter_params) { { date_of_birth_from: nil, date_of_birth_to: nil } }

        it { is_expected.to be_empty }
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

        it { is_expected.to contain_exactly(proposed_move) }
      end

      context 'with multiple statuses' do
        let(:filter_params) { { status: 'requested,completed,booked,in_transit' } }

        it { is_expected.to contain_exactly(requested_move, completed_move, booked_move, in_transit_move) }
      end

      context 'with mis-matching status' do
        let(:filter_params) { { status: 'fruit bats' } }

        it { is_expected.to be_empty }
      end
    end

    describe 'by move_type' do
      let!(:court_appearance_move) { create :move, :court_appearance }
      let!(:prison_recall_move) { create :move, :prison_recall }
      let!(:prison_transfer_move) { create :move, :prison_transfer }
      let!(:police_transfer_move) { create :move, :police_transfer }

      context 'with matching move_type' do
        let(:filter_params) { { move_type: 'court_appearance' } }

        it { is_expected.to contain_exactly(court_appearance_move) }
      end

      context 'with multiple move_types' do
        let(:filter_params) { { move_type: 'prison_transfer,prison_recall,police_transfer' } }

        it { is_expected.to contain_exactly(prison_recall_move, prison_transfer_move, police_transfer_move) }
      end

      context 'with mis-matching move_type' do
        let(:filter_params) { { move_type: 'fruit bats' } }

        it { is_expected.to be_empty }
      end
    end

    describe 'by cancellation_reason' do
      let!(:cancelled_made_in_error_move) { create :move, :cancelled_made_in_error }
      let!(:cancelled_rejected_move) { create :move, :cancelled_rejected }
      let!(:cancelled_other_move) { create :move, :cancelled_other }

      before { create :move, :cancelled_supplier_declined_to_move }

      context 'with nil cancellation reason' do
        let(:filter_params) { { cancellation_reason: nil } }

        it { is_expected.to be_empty }
      end

      context 'with empty cancellation reason' do
        let(:filter_params) { { cancellation_reason: '' } }
        let!(:prison_recall_move) { create :move, :prison_recall }

        it { is_expected.to contain_exactly(prison_recall_move) }
      end

      context 'with matching cancellation_reason' do
        let(:filter_params) { { cancellation_reason: 'other' } }

        it { is_expected.to contain_exactly(cancelled_other_move) }
      end

      context 'with multiple cancellation_reasons' do
        let(:filter_params) { { cancellation_reason: 'made_in_error,rejected' } }

        it { is_expected.to contain_exactly(cancelled_made_in_error_move, cancelled_rejected_move) }
      end

      context 'with mis-matching cancellation_reason' do
        let(:filter_params) { { cancellation_reason: 'fruit bats' } }

        it { is_expected.to be_empty }
      end
    end

    describe 'by rejection_reason' do
      let!(:rejected_no_space) { create :move, :rejected_no_space }
      let!(:rejected_no_transport) { create :move, :rejected_no_transport }

      context 'with nil rejection reason' do
        let(:filter_params) { { rejection_reason: nil } }

        it { is_expected.to be_empty }
      end

      context 'with empty rejection reason' do
        let(:filter_params) { { rejection_reason: '' } }
        let!(:prison_recall_move) { create :move, :prison_recall }

        it { is_expected.to contain_exactly(prison_recall_move) }
      end

      context 'with matching rejection' do
        let(:filter_params) { { rejection_reason: 'no_space_at_receiving_prison' } }

        it { is_expected.to contain_exactly(rejected_no_space) }
      end

      context 'with multiple rejection' do
        let(:filter_params) { { rejection_reason: 'no_space_at_receiving_prison,no_transport_available' } }

        it { is_expected.to contain_exactly(rejected_no_space, rejected_no_transport) }
      end

      context 'with mis-matching rejection' do
        let(:filter_params) { { rejection_reason: 'arm stuck in a packet of cornflakes' } }

        it { is_expected.to be_empty }
      end
    end

    describe 'by has_relationship_to_allocation' do
      let!(:move_with_allocation) { create(:move, :with_allocation) }
      let!(:move_without_allocation) { create(:move) }

      context 'with wrong type passed to has_relationship_to_allocation filter' do
        let(:filter_params) { { has_relationship_to_allocation: Random.uuid } }

        it { is_expected.to contain_exactly(move_with_allocation, move_without_allocation) }
      end

      context 'with has_relationship_to_allocation set as `nil`' do
        let(:filter_params) { { has_relationship_to_allocation: nil } }

        it { is_expected.to contain_exactly(move_with_allocation, move_without_allocation) }
      end

      context 'with has_relationship_to_allocation set as `false`' do
        let(:filter_params) { { has_relationship_to_allocation: 'false' } }

        it { is_expected.to contain_exactly(move_without_allocation) }
      end

      context 'with has_relationship_to_allocation set as `true`' do
        let(:filter_params) { { has_relationship_to_allocation: 'true' } }

        it { is_expected.to contain_exactly(move_with_allocation) }
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

      it 'ordered by location' do
        expect(results.map(&:to_location).pluck(:title)).to eql(%w[LOCATION1 Location2 LOCATION3])
      end
    end

    describe 'by profile_id' do
      let(:profile) { create :profile }
      let!(:move) { create :move, profile: }

      context 'with matching profile filter' do
        let(:filter_params) { { profile_id: profile.id } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with two profile filters' do
        let(:second_move) { create :move }
        let(:filter_params) { { profile_id: [profile.id, second_move.profile_id] } }

        it { is_expected.to contain_exactly(move, second_move) }
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { profile_id: Random.uuid } }

        it { is_expected.to be_empty }
      end
    end

    describe 'by person_id' do
      let(:person) { create :person }
      let!(:move) { create :move, person: }

      context 'with matching profile filter' do
        let(:filter_params) { { person_id: person.id } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with two profile filters' do
        let(:second_move) { create :move }
        let(:filter_params) { { person_id: [person.id, second_move.person_id] } }

        it { is_expected.to contain_exactly(move, second_move) }
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { person_id: Random.uuid } }

        it { is_expected.to be_empty }
      end
    end

    describe 'by reference' do
      let(:reference) { SecureRandom.uuid }
      let!(:move) { create :move, reference: }

      context 'with matching profile filter' do
        let(:filter_params) { { reference: } }

        it { is_expected.to contain_exactly(move) }
      end

      context 'with two profile filters' do
        let(:second_move) { create :move }
        let(:filter_params) { { reference: [reference, second_move.reference] } }

        it { is_expected.to contain_exactly(move, second_move) }
      end

      context 'with mis-matching location filter' do
        let(:filter_params) { { reference: Random.uuid } }

        it { is_expected.to be_empty }
      end
    end
  end

  context 'with 1 lodging' do
    let(:move) { create(:move, date: '2022-01-01') }
    let(:middle_location) { create(:location) }

    before do
      create(:lodging, move:, start_date: '2022-01-01', end_date: '2022-01-02', location: middle_location)
    end

    context 'and day one, outgoing, first location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.from_location_id] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day one, outgoing, second location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [middle_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, outgoing, third location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, first location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, second location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [middle_location] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day one, incoming, third location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, outgoing, first location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, outgoing, second location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [middle_location] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day two, outgoing, third location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, first location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, second location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [middle_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, third location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.to_location_id] } }

      it { is_expected.to contain_exactly(move) }
    end
  end

  context 'with 1 lodging not on the start date of the move' do
    let(:move) { create(:move, date: '2022-01-01') }
    let(:middle_location) { create(:location) }

    before do
      create(:lodging, move:, start_date: '2022-01-02', end_date: '2022-01-03', location: middle_location)
    end

    context 'and day one, outgoing, first location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, outgoing, second location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [middle_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, outgoing, third location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, first location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, second location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [middle_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, third location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, outgoing, first location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.from_location_id] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day two, outgoing, second location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [middle_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, outgoing, third location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, first location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, second location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [middle_location] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day two, incoming, third location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day three, outgoing, first location' do
      let(:filter_params) { { date_from: '2022-01-03', date_to: '2022-01-03', from_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day three, outgoing, second location' do
      let(:filter_params) { { date_from: '2022-01-03', date_to: '2022-01-03', from_location_id: [middle_location] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day three, outgoing, third location' do
      let(:filter_params) { { date_from: '2022-01-03', date_to: '2022-01-03', from_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day three, incoming, first location' do
      let(:filter_params) { { date_from: '2022-01-03', date_to: '2022-01-03', to_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day three, incoming, second location' do
      let(:filter_params) { { date_from: '2022-01-03', date_to: '2022-01-03', to_location_id: [middle_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day three, incoming, third location' do
      let(:filter_params) { { date_from: '2022-01-03', date_to: '2022-01-03', to_location_id: [move.to_location_id] } }

      it { is_expected.to contain_exactly(move) }
    end
  end

  context 'with 3 lodgings not on the start date of the move' do
    let(:move) { create(:move, date: '2022-01-01') }
    let!(:lodging1) { create(:lodging, move:, start_date: '2022-01-02', end_date: '2022-01-03') }
    let!(:lodging2) { create(:lodging, move:, start_date: '2022-01-03', end_date: '2022-01-05') }
    let!(:lodging3) { create(:lodging, move:, start_date: '2022-01-05', end_date: '2022-01-09') }
    let(:filter_params) { { date_from: date, date_to: date, id_field => location.id } }

    # Other lodgings outside of the date range
    let(:move2) { create(:move, date: '2022-02-01', from_location: move.from_location, to_location: move.to_location) }
    let!(:lodging4) { create(:lodging, move: move2, start_date: '2022-02-02', end_date: '2022-02-03') }
    let!(:lodging5) { create(:lodging, move: move2, start_date: '2022-02-03', end_date: '2022-02-05') }
    let!(:lodging6) { create(:lodging, move: move2, start_date: '2022-02-05', end_date: '2022-02-09') }

    context 'and day 1' do
      let(:date) { '2022-01-01' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 2' do
      let(:date) { '2022-01-02' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to contain_exactly(move) }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to contain_exactly(move) }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 3' do
      let(:date) { '2022-01-03' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to contain_exactly(move) }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to contain_exactly(move) }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 4' do
      let(:date) { '2022-01-04' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 5' do
      let(:date) { '2022-01-05' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to contain_exactly(move) }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end

        context 'when the journey does not go from location 3' do
          let(:journey_location) { create(:location) }
          let!(:journey) { create(:journey, move:, date: '2022-01-05', from_location: journey_location, to_location: lodging3.location) }
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to contain_exactly(move) }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end

        context 'when the journey does not go to location 4' do
          let(:journey_location) { create(:location) }
          let!(:journey) { create(:journey, move:, date: '2022-01-05', from_location: lodging2.location, to_location: journey_location) }
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 6' do
      let(:date) { '2022-01-06' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 7' do
      let(:date) { '2022-01-07' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 8' do
      let(:date) { '2022-01-08' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end
    end

    context 'and day 9' do
      let(:date) { '2022-01-09' }

      context 'when outgoing' do
        let(:id_field) { :from_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to contain_exactly(move) }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to be_empty }
        end
      end

      context 'when incoming' do
        let(:id_field) { :to_location_id }

        context 'with location 1' do
          let(:location) { move.from_location }

          it { is_expected.to be_empty }
        end

        context 'with location 2' do
          let(:location) { lodging1.location }

          it { is_expected.to be_empty }
        end

        context 'with location 3' do
          let(:location) { lodging2.location }

          it { is_expected.to be_empty }
        end

        context 'with location 4' do
          let(:location) { lodging3.location }

          it { is_expected.to be_empty }
        end

        context 'with location 5' do
          let(:location) { move.to_location }

          it { is_expected.to contain_exactly(move) }
        end
      end
    end
  end

  context 'with different lodging and journey locations' do
    let(:move) { create(:move, date: '2022-01-01') }
    let(:lodge_location) { create(:location) }
    let(:journey_location) { create(:location) }

    before do
      create(:lodging, move:, start_date: '2022-01-01', end_date: '2022-01-02', location: lodge_location)
      create(:journey, move:, date: '2022-01-01', from_location: move.from_location, to_location: journey_location)
      create(:journey, move:, date: '2022-01-02', from_location: journey_location, to_location: move.to_location)
    end

    context 'and day one, outgoing, start location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.from_location_id] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day one, outgoing, lodge location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [lodge_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, outgoing, journey location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [journey_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, outgoing, final location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', from_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, start location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, lodge location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [lodge_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day one, incoming, journey location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [journey_location] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day one, incoming, final location' do
      let(:filter_params) { { date_from: '2022-01-01', date_to: '2022-01-01', to_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, outgoing, start location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, outgoing, lodge location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [lodge_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, outgoing, journey location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [journey_location] } }

      it { is_expected.to contain_exactly(move) }
    end

    context 'and day two, outgoing, final location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', from_location_id: [move.to_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, start location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.from_location_id] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, lodge location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [lodge_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, journey location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [journey_location] } }

      it { is_expected.to be_empty }
    end

    context 'and day two, incoming, final location' do
      let(:filter_params) { { date_from: '2022-01-02', date_to: '2022-01-02', to_location_id: [move.to_location_id] } }

      it { is_expected.to contain_exactly(move) }
    end
  end
end
