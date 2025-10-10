# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
  it { is_expected.to belong_to(:supplier) }
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location).optional }
  it { is_expected.to belong_to(:profile).optional }
  it { is_expected.to belong_to(:allocation).optional }
  it { is_expected.to have_many(:notifications) }
  it { is_expected.to have_many(:journeys) }
  it { is_expected.to have_many(:generic_events) }
  it { is_expected.to have_many(:incident_events) }
  it { is_expected.to have_many(:notification_events) }
  it { is_expected.to have_one(:person_escort_record) }
  it { is_expected.to have_one(:youth_risk_assessment) }
  it { is_expected.to have_one(:extradition_flight) }

  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class.statuses.values) }

  describe 'cancellation_reason' do
    context 'when the move is not cancelled' do
      let(:move) { build(:move, status: 'requested') }

      it { expect(move).to validate_absence_of(:cancellation_reason) }
    end

    context 'when the move is cancelled' do
      let(:move) { build(:move, :cancelled) }

      it {
        expect(move).to validate_inclusion_of(:cancellation_reason)
          .in_array(described_class::CANCELLATION_REASONS)
      }
    end

    describe 'backward compatibility for move cancellation reasons' do
      let(:legacy_move_reasons) do
        %w[
          made_in_error
          supplier_declined_to_move
          rejected
          database_correction
          incomplete_per
          other
        ]
      end

      it 'includes all legacy move cancellation reasons for API compatibility' do
        legacy_move_reasons.each do |reason|
          expect(described_class::CANCELLATION_REASONS).to include(reason),
                                                           "Legacy move reason '#{reason}' is missing from Move::CANCELLATION_REASONS. " \
                                                           'This could break API clients using this reason for move cancellations.'
        end
      end
    end
  end

  describe 'rejection_reason' do
    context 'when the move is not rejected' do
      let(:move) { build(:move, status: 'requested') }

      it { expect(move).to validate_absence_of(:rejection_reason) }
    end

    context 'when the move is rejected' do
      let(:move) { build(:move, :cancelled, cancellation_reason: 'rejected') }

      it {
        expect(move).to validate_inclusion_of(:rejection_reason)
          .in_array(%w[
            no_space_at_receiving_prison
            no_transport_available
          ])
      }
    end
  end

  it 'validates presence of `to_location` if `move_type` is NOT prison_recall or video_remand' do
    expect(build(:move, move_type: 'prison_transfer')).to(
      validate_presence_of(:to_location),
    )
  end

  it 'does NOT validate presence of `to_location` if `move_type` is prison_recall' do
    expect(build(:move, move_type: 'prison_recall')).not_to(
      validate_presence_of(:to_location),
    )
  end

  it 'does NOT validate presence of `to_location` if `move_type` is video_remand' do
    expect(build(:move, move_type: 'video_remand')).not_to(
      validate_presence_of(:to_location),
    )
  end

  it 'validates presence of `profile` if `status` is proposed' do
    expect(build(:move, :proposed)).to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validates presence of `profile` if `status` is requested' do
    expect(build(:move, :requested)).not_to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validate presence of `profile` if `status` is booked' do
    expect(build(:move, :booked)).not_to(
      validate_presence_of(:profile),
    )
  end

  it 'validates presence of `profile` if `status` is in_transit' do
    expect(build(:move, :in_transit)).to(
      validate_presence_of(:profile),
    )
  end

  it 'validates presence of `profile` if `status` is completed' do
    expect(build(:move, :completed)).to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validates presence of `profile` if `status` is cancelled' do
    expect(build(:move, :cancelled)).not_to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validate uniqueness of `date` if `status` is cancelled' do
    # NB: uniqueness test requires create() not build()
    expect(create(:move, :cancelled)).not_to(
      validate_uniqueness_of(:date),
    )
  end

  it 'does NOT validate presence of `date` if `status` is cancelled' do
    expect(build(:move, :cancelled)).not_to(
      validate_presence_of(:date),
    )
  end

  it 'does NOT validate uniqueness of `date` if `status` is proposed' do
    # NB: uniqueness test requires create() not build()
    expect(create(:move, :proposed)).not_to(
      validate_uniqueness_of(:date),
    )
  end

  it 'does NOT validate uniqueness of `date` if `profile_id` is nil' do
    create(:move, :requested, profile: nil)

    expect(build(:move, :requested, profile: nil)).to be_valid
  end

  it 'validates presence of `date` if `status` is NOT proposed' do
    expect(build(:move)).to(
      validate_presence_of(:date),
    )
  end

  it 'does NOT validate presence of `date` if `status` is proposed' do
    expect(build(:move, status: :proposed)).not_to(
      validate_presence_of(:date),
    )
  end

  it 'validates presence of `date_from` if `status` is proposed' do
    expect(build(:move, status: :proposed)).to(
      validate_presence_of(:date_from),
    )
  end

  it 'does NOT validate presence of `date_from` if `status` is NOT proposed' do
    expect(build(:move)).not_to(
      validate_presence_of(:date_from),
    )
  end

  it 'prevents date_from > date_to' do
    expect(build(:move, date_from: '2020-03-04', date_to: '2020-03-03')).not_to be_valid
  end

  it 'allows date_from == date_to' do
    expect(build(:move, date_from: '2020-03-04', date_to: '2020-03-04')).to be_valid
  end

  it 'allows a valid date for recall_date' do
    expect(build(:move, recall_date: '2023-01-05')).to be_valid
  end

  it 'allows a nil date for recall_date' do
    expect(build(:move, recall_date: nil)).to be_valid
  end

  it 'does not allow an invalid date for recall_date' do
    expect(build(:move, recall_date: 'not a date')).not_to be_valid
  end

  it 'allows a move_type of `extradition` if the `to_location` is permitted' do
    to_location = build(:location, extradition_capable: true)
    expect(build(:move, move_type: 'extradition', to_location:)).to be_valid
  end

  it 'does not allow a move_type of `extradition` if the `to_location` is not permitted' do
    to_location = build(:location, extradition_capable: nil)
    expect(build(:move, move_type: 'extradition', to_location:)).not_to be_valid
  end

  context 'when the from_location and to_location are the same' do
    subject(:move) { build(:move, to_location: location, from_location: location) }

    let(:location) { create(:location) }

    it 'is not valid' do
      expect(move).not_to be_valid
      expect(move.errors[:to_location_id]).to eq(['should be different to the from location'])
    end
  end

  context 'with a lockout move' do
    subject(:move) { create(:move) }

    before do
      create(:event_move_lockout, eventable: move)
    end

    it 'allows identical to and from locations' do
      move.to_location = move.from_location
      expect(move).to be_valid
    end
  end

  context 'when the profile has a prisoner category' do
    it 'prevents an unsupported category from being moved' do
      expect(build(:move, profile: build(:profile, :category_not_supported))).not_to be_valid
    end

    it 'allows a supported category to be moved' do
      expect(build(:move, profile: build(:profile, :category_supported))).to be_valid
    end
  end

  context 'when a Move for a Person has already been created' do
    let(:move) { create(:move) }

    let(:profile_for_new_move) { create(:profile, person: move.person) }

    context 'when creating a new Move with the same from_location, to_location and date' do
      it 'returns a validation error on date' do
        new_move = described_class.create(profile: profile_for_new_move,  # rubocop:disable Rails/SaveBang
                                          from_location: move.from_location,
                                          to_location: move.to_location,
                                          date: move.date)

        expect(new_move.errors[:date]).to eq(['has already been taken'])
      end
    end

    context 'when creating a new Move in Proposed status' do
      it 'returns a valid Move' do
        new_move = described_class.create(profile: profile_for_new_move,  # rubocop:disable Rails/SaveBang
                                          from_location: move.from_location,
                                          to_location: move.to_location,
                                          date: move.date,
                                          status: Move::MOVE_STATUS_PROPOSED)

        expect(new_move.errors[:date]).to be_empty
      end
    end

    context 'when creating a new Move having to_location empty' do
      it 'returns a validation error on date' do
        new_move = described_class.create(profile: profile_for_new_move,  # rubocop:disable Rails/SaveBang
                                          from_location: move.from_location,
                                          to_location: nil,
                                          date: move.date,
                                          status: Move::MOVE_STATUS_PROPOSED)

        expect(new_move.errors[:date]).to be_empty
      end
    end
  end

  context 'without automatic reference generation' do
    before do
      service = instance_double(Moves::ReferenceGenerator, call: nil)
      allow(Moves::ReferenceGenerator).to receive(:new).and_return(service)
    end

    it { is_expected.to validate_presence_of(:reference) }
  end

  describe '#for_supplier' do
    subject(:moves) { described_class.for_supplier(supplier) }

    let(:supplier) { create(:supplier) }
    let(:location) { create(:location, suppliers: [supplier]) }
    let(:location2) { create(:location, suppliers: [supplier]) }

    let(:move1) { create(:move, supplier:) }
    let(:move2) { create(:move, to_location: location) }
    let(:move3) { create(:move, from_location: location) }
    let(:move4) { create(:move) }
    let(:move5) { create(:move) }

    before { create(:lodging, location: location2, move: move5) }

    it { is_expected.to include(move1) }
    it { is_expected.to include(move2) }
    it { is_expected.to include(move3) }
    it { is_expected.not_to include(move4) }
    it { is_expected.to include(move5) }
  end

  describe '#reference' do
    subject(:move) { described_class.new }

    it 'generates a new unique reference before validation' do
      move.valid?
      expect(move.reference).to be_present
    end

    it 'does not overwrite an existing reference on validation' do
      move = described_class.new(reference: '12345678')
      expect(move.reference).to eq '12345678'
    end
  end

  describe '#move_type' do
    subject(:move) { build :move, from_location:, to_location:, move_type:, version: }

    let(:from_location) { build :location, :police }
    let(:move_type) { nil }
    let(:version) { nil }

    before { move.valid? }

    context 'when creating a v2 move' do
      let(:version) { 2 }
      let(:to_location) { nil }

      context 'without specifying move_type' do
        it 'does not set move_type' do
          expect(move.move_type).to be_nil
        end

        it 'is not valid' do
          expect(move).not_to be_valid
        end
      end

      context 'when specifying move_type' do
        let(:move_type) { 'prison_recall' }

        it 'is valid' do
          expect(move).to be_valid
        end
      end
    end

    context 'when to_location is empty' do
      let(:to_location) { nil }

      it 'sets the move type to `prison_recall` at validation time' do
        expect(move.move_type).to eq 'prison_recall'
      end
    end

    context 'when to_location is a Court' do
      let(:to_location) { build :location, :court }

      it 'sets the move type to `court_appearance` at validation time' do
        expect(move.move_type).to eq 'court_appearance'
      end
    end

    context 'when to_location is a Prison' do
      let(:to_location) { build :location }

      it 'sets the move type to `prison_transfer` at validation time' do
        expect(move.move_type).to eq 'prison_transfer'
      end
    end

    context 'when both to_location and from_location are police locations' do
      let(:to_location) { build :location, :police }
      let(:from_location) { build :location, :police }

      it 'sets move_type to `police_transfer`' do
        expect(move.move_type).to eq 'police_transfer'
      end
    end
  end

  describe '#existing_moves' do
    let!(:move) { create :move }

    context 'with a duplicate move with the same profile' do
      let(:duplicate) { described_class.new(move.attributes.merge(id: nil)) }

      it 'finds the existing_moves' do
        expect(duplicate.existing_moves.first).to eq(move)
        expect(duplicate.existing_moves.count).to eq(1)
      end
    end

    context 'with a duplicate move with a different profile' do
      let(:other_profile) { create(:profile, person: move.person) }
      let(:duplicate) { described_class.new(move.attributes.merge(id: nil, profile: other_profile)) }

      it 'finds the existing_moves' do
        expect(duplicate.existing_moves.first).to eq(move)
        expect(duplicate.existing_moves.count).to eq(1)
      end
    end

    context 'with a cancelled duplicate move' do
      let(:duplicate) { described_class.new(move.attributes.merge(id: nil, status: 'requested')) }

      it 'ignores cancelled moves' do
        move.cancel!(cancellation_reason: 'made_in_error')
        expect(duplicate.existing_moves).to be_empty
      end
    end

    context 'with a proposed duplicate move' do
      let(:duplicate) { described_class.new(move.attributes.merge(id: nil, status: 'requested')) }

      it 'ignores proposed moves' do
        move.update!(status: :proposed)
        expect(duplicate.existing_moves).to be_empty
      end
    end
  end

  describe '#existing_id' do
    context 'when there is no existing move' do
      let!(:move) { build :move }

      it 'returns nil' do
        expect(move.existing_id).to be_nil
      end
    end

    context 'when there is an existing move' do
      let!(:move) { create :move }
      let(:duplicate) { described_class.new(move.attributes.merge(id: nil)) }

      it 'finds the existing_moves' do
        expect(duplicate.existing_id).to eq(move.id)
      end
    end
  end

  describe '#rejected?' do
    subject { move.rejected? }

    context 'with cancellation_reason of rejected' do
      let(:move) { build :move, cancellation_reason: 'rejected' }

      it { is_expected.to be true }
    end

    context 'with cancellation_reason not rejected' do
      let(:move) { build :move, cancellation_reason: 'other' }

      it { is_expected.to be false }
    end
  end

  describe '#current?' do
    subject { move.current? }

    context 'with date' do
      context 'when yesterday' do
        let(:move) { build :move, date: 1.day.ago }

        it { is_expected.to be false }
      end

      context 'when today' do
        let(:move) { build :move, date: Time.zone.today }

        it { is_expected.to be true }
      end

      context 'when tomorrow' do
        let(:move) { build :move, date: 1.day.from_now }

        it { is_expected.to be true }
      end
    end

    context 'with date_to' do
      context 'when yesterday' do
        let(:move) { build :move, date: nil, date_to: 1.day.ago }

        it { is_expected.to be false }
      end

      context 'when today' do
        let(:move) { build :move, date: nil, date_to: Time.zone.today }

        it { is_expected.to be true }
      end

      context 'when tomorrow' do
        let(:move) { build :move, date: nil, date_to: 1.day.from_now }

        it { is_expected.to be true }
      end
    end

    context 'with date_from' do
      context 'when yesterday' do
        let(:move) { build :move, date: nil, date_to: nil, date_from: 1.day.ago }

        it { is_expected.to be false }
      end

      context 'when today' do
        let(:move) { build :move, date: nil, date_to: nil, date_from: Time.zone.today }

        it { is_expected.to be true }
      end

      context 'when tomorrow' do
        let(:move) { build :move, date: nil, date_to: nil, date_from: 1.day.from_now }

        it { is_expected.to be true }
      end
    end
  end

  describe '#rebook' do
    before do
      create :supplier_location, supplier: original_move.supplier, location: original_move.from_location
    end

    let(:original_move) { create(:move, :proposed, :with_allocation, :with_date_to) }

    context 'when not yet rebooked' do
      it 'creates a new move' do
        expect { original_move.rebook }.to change(described_class, :count).by(1)
      end

      it 'copies the original move from location' do
        expect(original_move.rebook.from_location_id).to eq(original_move.from_location_id)
      end

      it 'copies the original move to location' do
        expect(original_move.rebook.to_location_id).to eq(original_move.to_location_id)
      end

      it 'copies the original move profile' do
        expect(original_move.rebook.profile_id).to eq(original_move.profile_id)
      end

      it 'copies the original move allocation' do
        expect(original_move.rebook.allocation_id).to eq(original_move.allocation_id)
      end

      it 'sets the move status to proposed' do
        expect(original_move.rebook.status).to eq('proposed')
      end

      it 'sets the move date to 7 days in the future if present' do
        expect(original_move.rebook.date).to eq(original_move.date + 7.days)
      end

      it 'sets the move date to nil if not present' do
        original_move.date = nil
        expect(original_move.rebook.date).to be_nil
      end

      it 'sets the move from date to 7 days in the future if present' do
        expect(original_move.rebook.date_from).to eq(original_move.date_from + 7.days)
      end

      it 'raises an error if date_from is nil' do
        original_move.date_from = nil

        expect {
          original_move.rebook.date_from
        }.to raise_exception ActiveRecord::RecordInvalid
      end

      it 'sets the move to date to 7 days in the future if present' do
        expect(original_move.rebook.date_to).to eq(original_move.date_to + 7.days)
      end

      it 'sets the move to date to nil if not present' do
        original_move.date_to = nil
        expect(original_move.rebook.date_to).to be_nil
      end

      it 'relates the new move to the original move' do
        expect(original_move.rebook.original_move).to eq(original_move)
      end
    end

    context 'when previously rebooked' do
      it 'does not create a new move' do
        original_move.rebook
        expect { original_move.rebook }.not_to change(described_class, :count)
      end

      it 'returns the previously rebooked move' do
        rebooked_before = original_move.rebook
        expect(original_move.rebook).to eq(rebooked_before)
      end
    end
  end

  describe '.unfilled?' do
    it 'returns true if there are no profiles linked to a move' do
      create_list(:move, 2, profile: nil)

      expect(described_class).to be_unfilled
    end

    it 'returns true if not all moves have profiles linked' do
      create(:move, profile: nil)
      create(:move)

      expect(described_class).to be_unfilled
    end

    it 'returns false if all moves are associated to a profile' do
      create_list(:move, 2)

      expect(described_class).not_to be_unfilled
    end

    it 'returns true if no moves are present' do
      expect(described_class).to be_unfilled
    end
  end

  context 'with versioning' do
    let(:move) { create(:move) }

    it 'has a version record for creating the move' do
      expect(move.versions.map(&:event)).to eq(%w[create])
    end

    it 'does not create a profile version record if move is touched' do
      expect {
        move.touch
      }.not_to change(move.profile.versions, :count)
    end

    it 'does not create a move version record if move is touched' do
      move.touch
      expect(move.versions.count).to eq 1
    end

    it 'does not create a profile version record if only changing move updated_at timestamp' do
      expect {
        move.update(updated_at: Time.zone.now)
      }.not_to change(move.profile.versions, :count)
    end

    it 'does not create a move version record if only changing move updated_at timestamp' do
      move.update!(updated_at: Time.zone.now)
      expect(move.versions.count).to eq 1
    end

    it 'does not create a profile version record if other move attributes are changed' do
      expect {
        move.update(additional_information: 'Foo')
      }.not_to change(move.profile.versions, :count)
    end

    it 'creates a move version record if other move attributes are changed' do
      move.update!(additional_information: 'Bar')
      expect(move.versions.count).to eq 2
    end

    it 'stores original move attributes in new version record when other move attributes are changed' do
      previous_move_attributes = move.attributes
      move.update!(additional_information: 'Bar')
      expect(move.versions.last.reify.attributes).to eq previous_move_attributes
    end
  end

  describe '#for_feed' do
    subject(:move) { create(:move, :with_person_escort_record) }

    let(:expected_json) do
      {
        'id' => move.id,
        'additional_information' => 'some more info about the move that the supplier might need to know',
        'allocation_id' => nil,
        'cancellation_reason' => nil,
        'cancellation_reason_comment' => nil,
        'created_at' => be_a(Time),
        'date' => be_a(Date),
        'date_from' => be_a(Date),
        'date_to' => nil,
        'from_location' => 'PEI',
        'from_location_type' => 'prison',
        'move_agreed' => nil,
        'move_agreed_by' => nil,
        'move_type' => 'court_appearance',
        'profile_id' => move.profile_id,
        'reason_comment' => nil,
        'reference' => move.reference,
        'rejection_reason' => nil,
        'status' => 'requested',
        'time_due' => be_a(Time),
        'to_location' => 'GUICCT',
        'to_location_type' => 'court',
        'updated_at' => be_a(Time),
        'supplier' => move.supplier.key,
        'person_escort_record_id' => move.person_escort_record_id,
      }
    end

    it 'generates a feed document' do
      expect(move.for_feed).to include_json(expected_json)
    end
  end

  describe 'relationships' do
    it 'updates the parent record when updated' do
      profile = create(:profile)
      move = create(:move, profile:)

      expect { move.update(date: move.date + 1.day) }.to(change { profile.reload.updated_at })
    end

    it 'updates the parent record when created' do
      profile = create(:profile)

      expect { create(:move, profile:) }.to(change { profile.reload.updated_at })
    end
  end

  describe '#handle_event_run' do
    subject(:move) { create(:move) }

    before do
      allow(Notifier).to receive(:prepare_notifications)
    end

    context 'when the move has not changed' do
      it 'returns false' do
        expect(move.handle_event_run).to be(false)
      end

      it 'does not trigger a move notification' do
        move.handle_event_run

        expect(Notifier).not_to have_received(:prepare_notifications)
      end
    end

    context 'when the move status has changed' do
      before do
        move.status = 'in_transit'
      end

      it 'returns true' do
        expect(move.handle_event_run).to be(true)
      end

      it 'saves the move' do
        move.handle_event_run

        expect(move.reload.status).to eq('in_transit')
      end

      context 'with an allocation' do
        subject(:move) { create(:move, allocation:) }

        let(:allocation) { create(:allocation) }

        before { allow(allocation).to receive(:refresh_status_and_moves_count!) }

        it 'updates the allocation' do
          move.handle_event_run

          expect(allocation).to have_received(:refresh_status_and_moves_count!)
        end
      end

      it 'triggers a move notification' do
        move.handle_event_run

        expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update_status')
      end
    end

    context 'when the move date has changed' do
      before do
        move.date = new_date
      end

      let(:new_date) { move.date + 1.day }

      it 'returns true' do
        expect(move.handle_event_run).to be(true)
      end

      it 'saves the move' do
        move.handle_event_run

        expect(move.reload.date).to eq(new_date)
      end

      it 'triggers a move notification' do
        move.handle_event_run

        expect(Notifier).to have_received(:prepare_notifications).with(topic: move, action_name: 'update')
      end
    end

    context 'when dry_run: true' do
      before do
        move.status = 'in_transit'
      end

      it 'does not save the move' do
        move.handle_event_run(dry_run: true)

        expect(move.changed?).to be true
        expect(move.reload.status).to eq('requested')
      end
    end
  end

  describe '#all_events_for_timeline' do
    subject(:all_events_for_timeline) { move.all_events_for_timeline }

    let(:move) { create(:move, :with_journey, profile: create(:profile, :with_person_escort_record)) }
    let(:now) { Time.zone.now }

    context 'when there are no events' do
      it 'returns an empty Array' do
        expect(all_events_for_timeline).to eq([])
      end
    end

    context 'when there are events for each eventable' do
      let(:lodging) { create(:lodging, move:) }
      let!(:first_event) { create(:event_move_cancel, eventable: move, occurred_at: now + 2.seconds) }
      let!(:second_event) { create(:event_person_move_death_in_custody, eventable: move.profile.person, occurred_at: now + 1.second) }
      let!(:third_event) { create(:event_move_approve, eventable: move, occurred_at: now) }
      let!(:fourth_event) { create(:event_per_court_cell_share_risk_assessment, eventable: move.profile.person_escort_record, occurred_at: now - 1.second) }
      let!(:fifth_event) { create(:event_journey_person_boards_vehicle, eventable: move.journeys.first, occurred_at: now - 2.seconds) }
      let!(:sixth_event) { create(:event_lodging_create, eventable: lodging, occurred_at: now - 3.seconds) }

      it 'returns generic events in the correct order' do
        expect(all_events_for_timeline.pluck(:id)).to eq([sixth_event, fifth_event, fourth_event, third_event, second_event, first_event].map(&:id))
      end
    end

    context 'when there are events for only one eventable' do
      let!(:first_event) { create(:event_move_cancel, eventable: move, occurred_at: now + 2.seconds) }
      let!(:second_event) { create(:event_move_approve, eventable: move, occurred_at: now) }

      it 'returns generic events in the correct order' do
        expect(all_events_for_timeline.pluck(:id)).to eq([second_event, first_event].map(&:id))
      end
    end
  end

  describe '#important_events' do
    subject(:important_events) { move.important_events }

    let(:move) { create(:move, profile: create(:profile, :with_person_escort_record)) }

    context 'when there are no events' do
      it { is_expected.to be_empty }
    end

    context 'when there are move incident events' do
      let!(:important_event) { create(:event_person_move_assault, eventable: move) }

      before { create(:event_move_approve, eventable: move) }

      it { is_expected.to match_array([important_event]) }
    end

    context 'when there are PER medical events' do
      let(:person_escort_record) { move.profile.person_escort_record }
      let!(:important_event) { create(:event_per_medical_aid, eventable: person_escort_record) }

      before { create(:event_per_prisoner_welfare, eventable: person_escort_record) }

      it { is_expected.to match_array([important_event]) }
    end

    context 'when there are move incident and PER medical events' do
      let(:person_escort_record) { move.profile.person_escort_record }
      let!(:first_event) { create(:event_person_move_assault, eventable: move) }
      let!(:second_event) { create(:event_per_medical_aid, eventable: person_escort_record) }
      let!(:third_event) { create(:event_per_suicide_and_self_harm, eventable: person_escort_record) }

      it { is_expected.to match_array([first_event, second_event, third_event]) }
    end

    context 'when there are PER property change events' do
      let(:person_escort_record) { move.profile.person_escort_record }
      let!(:important_event) { create(:event_per_property_change, eventable: person_escort_record) }

      it { is_expected.to match_array([important_event]) }
    end

    context 'when there are PER handover events' do
      let(:person_escort_record) { move.profile.person_escort_record }
      let!(:important_event) { create(:event_per_handover, eventable: person_escort_record) }

      it { is_expected.to match_array([important_event]) }
    end

    context 'when there are lodging end events' do
      let!(:important_event) { create(:event_move_lodging_end, eventable: move) }

      it { is_expected.to match_array([important_event]) }
    end

    context 'when there are lodging start events' do
      let!(:important_event) { create(:event_move_lodging_start, eventable: move) }

      it { is_expected.to match_array([important_event]) }
    end
  end

  describe '#vehicle_registration' do
    it 'returns nothing if no journeys present' do
      move = create(:move)

      expect(move.vehicle_registration).to be_nil
    end

    it 'returns nothing if a journey is present but no vehicle registration available' do
      move = create(:move, journeys: [create(:journey, vehicle: {})])

      expect(move.vehicle_registration).to be_nil
    end

    it 'returns the vehicle registration number of a journey' do
      move = create(:move, :with_journey)

      expect(move.vehicle_registration).to eq('AB12 CDE')
    end

    it 'returns the latest vehicle registration number if multiple journeys present' do
      journey1 = create(:journey, client_timestamp: Time.zone.now - 1.day, vehicle: { id: '12345', registration: 'AB12 CDE' })
      journey2 = create(:journey, client_timestamp: Time.zone.now - 2.days, vehicle: { id: '6789', registration: 'CD12 ABC' })
      move = create(:move, journeys: [journey1, journey2])

      expect(move.vehicle_registration).to eq('AB12 CDE')
    end

    it 'returns latest vehicle registration for uncancelled journeys' do
      journey1 = create(:journey, :cancelled, client_timestamp: Time.zone.now - 1.day, vehicle: { id: '12345', registration: 'AB12 CDE' })
      journey2 = create(:journey, client_timestamp: Time.zone.now - 2.days, vehicle: { id: '6789', registration: 'CD12 ABC' })
      move = create(:move, journeys: [journey1, journey2])

      expect(move.vehicle_registration).to eq('CD12 ABC')
    end
  end

  describe '#expected_time_of_arrival' do
    it 'returns nothing if no events present' do
      move = create(:move)

      expect(move.expected_time_of_arrival).to be_nil
    end

    it 'returns nothing if a different notification event is present' do
      move = create(:move, notification_events: [create(:event_move_notify_premises_of_arrival_in30_mins)])

      expect(move.expected_time_of_arrival).to be_nil
    end

    it 'returns the expected time of arrival for a vehicle' do
      event = create(:event_move_notify_premises_of_drop_off_eta, expected_at: '2019-06-16T10:20:30+01:00')
      move = create(:move, notification_events: [event])

      expect(move.expected_time_of_arrival).to eq('2019-06-16T10:20:30+01:00')
    end

    it 'returns the expected time of arrival for a vehicle if multiple different notification events exist' do
      event1 = create(:event_move_notify_premises_of_drop_off_eta, expected_at: '2019-06-16T10:20:30+01:00', occurred_at: 2.minutes.ago)
      event2 = create(:event_move_notify_premises_of_expected_collection_time, expected_at: '2019-06-17T10:20:30+01:00', occurred_at: 1.minute.ago)
      move = create(:move, notification_events: [event2, event1])

      expect(move.expected_time_of_arrival).to eq('2019-06-16T10:20:30+01:00')
    end

    it 'returns the latest expected time of arrival for a vehicle if multiple events present' do
      event1 = create(:event_move_notify_premises_of_drop_off_eta, expected_at: '2019-06-16T10:20:30+01:00', occurred_at: 2.minutes.ago)
      event2 = create(:event_move_notify_premises_of_drop_off_eta, expected_at: '2019-06-17T10:20:30+01:00', occurred_at: 1.minute.ago)
      move = create(:move, notification_events: [event2, event1])

      expect(move.expected_time_of_arrival).to eq('2019-06-17T10:20:30+01:00')
    end
  end

  describe '#expected_collection_time' do
    it 'returns nothing if no events present' do
      move = create(:move)

      expect(move.expected_collection_time).to be_nil
    end

    it 'returns nothing if a different notification event is present' do
      move = create(:move, notification_events: [create(:event_move_notify_premises_of_arrival_in30_mins)])

      expect(move.expected_collection_time).to be_nil
    end

    it 'returns the expected collection time for a vehicle' do
      event = create(:event_move_notify_premises_of_expected_collection_time, expected_at: '2019-06-16T10:20:30+01:00')
      move = create(:move, notification_events: [event])

      expect(move.expected_collection_time).to eq('2019-06-16T10:20:30+01:00')
    end

    it 'returns the expected collection time for a vehicle if multiple different notification events exist' do
      event1 = create(:event_move_notify_premises_of_expected_collection_time, expected_at: '2019-06-16T10:20:30+01:00', occurred_at: 2.minutes.ago)
      event2 = create(:event_move_notify_premises_of_drop_off_eta, expected_at: '2019-06-17T10:20:30+01:00', occurred_at: 1.minute.ago)
      move = create(:move, notification_events: [event2, event1])

      expect(move.expected_collection_time).to eq('2019-06-16T10:20:30+01:00')
    end

    it 'returns the latest expected collection time for a vehicle if multiple events present' do
      event1 = create(:event_move_notify_premises_of_expected_collection_time, expected_at: '2019-06-16T10:20:30+01:00', occurred_at: 2.minutes.ago)
      event2 = create(:event_move_notify_premises_of_expected_collection_time, expected_at: '2019-06-17T10:20:30+01:00', occurred_at: 1.minute.ago)
      move = create(:move, notification_events: [event2, event1])

      expect(move.expected_collection_time).to eq('2019-06-17T10:20:30+01:00')
    end
  end

  describe '#cross_supplier?' do
    let(:move) { create(:move) }

    it { expect(move.cross_supplier?).to be false }

    context 'when the origin and destination suppliers are different' do
      let!(:supplier1) { create(:supplier) }
      let!(:supplier2) { create(:supplier) }
      let!(:from_location) { create(:location, suppliers: [supplier1]) }
      let!(:to_location) { create(:location, :court, suppliers: [supplier2]) }
      let(:move) { create(:move, from_location:, to_location:) }

      it { expect(move.cross_supplier?).to be true }
    end
  end

  describe '#billable?' do
    let!(:move) { create(:move, :with_journey) }

    it 'is not billable' do
      expect(move).not_to be_billable
    end

    context 'with a billable journey' do
      before { create(:journey, move: move, billable: true) }

      it 'is not billable' do
        expect(move).to be_billable
      end
    end
  end

  describe '#prisoner_location_description' do
    let(:prison_number) { 'A1234BC' }
    let(:person) { create(:person, prison_number: prison_number) }
    let(:profile) { create(:profile, person: person) }
    let(:move) { create(:move, profile: profile) }

    context 'when the API returns a location description' do
      let(:location_description) { 'HMP Leeds' }

      before do
        allow(PrisonerSearchApiClient::LocationDescription).to receive(:get).with(prison_number).and_return(location_description)
      end

      it 'returns the location description from the API' do
        expect(move.prisoner_location_description).to eq(location_description)
      end
    end

    context 'when the API returns nil' do
      before do
        allow(PrisonerSearchApiClient::LocationDescription).to receive(:get).with(prison_number).and_return(nil)
      end

      it 'returns nil' do
        expect(move.prisoner_location_description).to be_nil
      end
    end

    context 'when the prison_number is nil' do
      let(:prison_number) { nil }

      it 'returns nil' do
        expect(move.prisoner_location_description).to be_nil
      end
    end
  end
end
