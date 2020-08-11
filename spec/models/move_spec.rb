# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
  it { is_expected.to belong_to(:supplier).optional }
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location).optional }
  it { is_expected.to belong_to(:profile).optional }
  it { is_expected.to belong_to(:allocation).optional }
  it { is_expected.to have_many(:notifications) }
  it { is_expected.to have_many(:journeys) }
  it { is_expected.to have_many(:move_events) }

  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class.statuses.values) }

  describe 'cancellation_reason' do
    context 'when the move is not cancelled' do
      let(:move) { build(:move, status: 'requested') }

      it { expect(move).to validate_absence_of(:cancellation_reason) }
    end

    context 'when the move is cancelled' do
      let(:move) { build(:move, status: 'cancelled') }

      it {
        expect(move).to validate_inclusion_of(:cancellation_reason)
          .in_array(%w[
            made_in_error
            supplier_declined_to_move
            rejected
            other
          ])
      }
    end
  end

  describe 'rejection_reason' do
    context 'when the move is not rejected' do
      let(:move) { build(:move, status: 'requested') }

      it { expect(move).to validate_absence_of(:rejection_reason) }
    end

    context 'when the move is rejected' do
      let(:move) { build(:move, status: 'cancelled', cancellation_reason: 'rejected') }

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

  it 'validates presence of `profile` if `status` is NOT requested or cancelled' do
    expect(build(:move, :proposed)).to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validates presence of `profile` if `status` is requested' do
    expect(build(:move, :requested)).not_to(
      validate_presence_of(:profile),
    )
  end

  it 'validates presence of `profile` if `status` is booked' do
    expect(build(:move, :booked)).to(
      validate_presence_of(:profile),
    )
  end

  it 'validates presence of `profile` if `status` is in_transit' do
    expect(build(:move, :in_transit)).to(
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

  context 'when a Move for a Person has already been created' do
    let(:move) { create(:move) }

    let(:profile_for_new_move) { create(:profile, person: move.person) }

    context 'when creating a new Move with the same from_location, to_location and date' do
      it 'returns a validation error on date' do
        new_move = described_class.create(profile: profile_for_new_move,
                                          from_location: move.from_location,
                                          to_location: move.to_location,
                                          date: move.date)

        expect(new_move.errors[:date]).to eq(['has already been taken'])
      end
    end

    context 'when creating a new Move in Proposed status' do
      it 'returns a valid Move' do
        new_move = described_class.create(profile: profile_for_new_move,
                                          from_location: move.from_location,
                                          to_location: move.to_location,
                                          date: move.date,
                                          status: Move::MOVE_STATUS_PROPOSED)

        expect(new_move.errors[:date]).to be_empty
      end
    end

    context 'when creating a new Move having to_location empty' do
      it 'returns a validation error on date' do
        new_move = described_class.create(profile: profile_for_new_move,
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
      service = instance_double('Moves::ReferenceGenerator', call: nil)
      allow(Moves::ReferenceGenerator).to receive(:new).and_return(service)
    end

    it { is_expected.to validate_presence_of(:reference) }
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
    subject(:move) { build :move, from_location: from_location, to_location: to_location, move_type: move_type, version: version }

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

  describe '#existing' do
    let!(:move) { create :move }
    let(:duplicate) { described_class.new(move.attributes) }

    context 'when querying for existing moves' do
      it 'finds the right move' do
        expect(duplicate.existing).to eq(move)
      end

      it 'ignores cancelled moves' do
        move.update!(status: :cancelled, cancellation_reason: 'made_in_error')
        expect(duplicate.existing).to be_nil
      end
    end
  end

  describe '#existing_id' do
    let!(:move) { build :move }

    context 'when there is no existing move' do
      it 'returns nil' do
        expect(move.existing_id).to be_nil
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
    let!(:original_move) { create(:move, :proposed, :with_allocation, :with_date_to) }

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

      it 'sets the move date from to nil if not present' do
        original_move.date_from = nil
        expect(original_move.rebook.date_from).to be_nil
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

    it 'has a version record for the create' do
      expect(move.versions.map(&:event)).to eq(%w[create])
    end
  end

  describe '#for_feed' do
    subject(:move) { create(:move, :with_supplier) }

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
      }
    end

    it 'generates a feed document' do
      expect(move.for_feed).to include_json(expected_json)
    end
  end

  describe 'relationships' do
    it 'updates the parent record when updated' do
      profile = create(:profile)
      move = create(:move, profile: profile)

      expect { move.update(date: move.date + 1.day) }.to change { profile.reload.updated_at }
    end

    it 'updates the parent record when created' do
      profile = create(:profile)

      expect { create(:move, profile: profile) }.to change { profile.reload.updated_at }
    end
  end

  describe '.updated_at_from_and_to' do
    let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
    let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

    let!(:before_start_move) { create(:move, updated_at: updated_at_from - 1.second) }
    let!(:on_start_move) { create(:move, updated_at: updated_at_from) }
    let!(:on_end_move) {  create(:move, updated_at: updated_at_to) }
    let!(:after_end_move) { create(:move, updated_at: updated_at_to + 1.second) }

    it 'returns the expected moves' do
      actual_moves = described_class.updated_at_from_and_to(
        updated_at_from,
        updated_at_to,
      )
      expect(actual_moves).to eq([on_start_move, on_end_move])
    end
  end
end
