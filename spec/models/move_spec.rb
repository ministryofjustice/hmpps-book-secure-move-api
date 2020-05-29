# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
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

  it 'validates presence of `to_location` if `move_type` is NOT prison_recall' do
    expect(build(:move, move_type: 'prison_transfer')).to(
      validate_presence_of(:to_location),
    )
  end

  it 'does NOT validate presence of `to_location` if `move_type` is prison_recall' do
    expect(build(:move, move_type: 'prison_recall')).not_to(
      validate_presence_of(:to_location),
    )
  end

  it 'validates presence of `profile` if `status` is NOT requested, booked or cancelled' do
    expect(build(:move, status: :proposed)).to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validates presence of `profile` if `status` is requested' do
    expect(build(:move, status: :requested)).not_to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validates presence of `profile` if `status` is booked' do
    expect(build(:move, status: :booked)).not_to(
      validate_presence_of(:profile),
    )
  end

  it 'does NOT validates presence of `profile` if `status` is cancelled' do
    expect(build(:move, status: :cancelled)).not_to(
      validate_presence_of(:profile),
    )
  end

  it 'validates uniqueness of `date` if `status` is NOT proposed or cancelled' do
    expect(create(:move)).to(
      validate_uniqueness_of(:date).scoped_to(:status, :profile_id, :from_location_id, :to_location_id),
    )
  end

  it 'does NOT validate uniqueness of `date` if `status` is cancelled' do
    expect(build(:move, status: :cancelled)).not_to(
      validate_uniqueness_of(:date),
    )
  end

  it 'does NOT validate presence of `date` if `status` is cancelled' do
    expect(build(:move, status: :cancelled)).not_to(
      validate_presence_of(:date),
    )
  end

  it 'does NOT validate uniqueness of `date` if `status` is proposed' do
    expect(build(:move, status: :proposed)).not_to(
      validate_uniqueness_of(:date),
    )
  end

  it 'does NOT validate uniqueness of `date` if `profile_id` is nil' do
    expect(build(:move, status: :requested, profile: nil)).not_to(
      validate_uniqueness_of(:date),
    )
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

  it 'does NOT permit duplicate nomis_event_ids' do
    move = create(:move, nomis_event_ids: [123_456])
    move.nomis_event_ids << 123_456
    move.save
    expect(move.nomis_event_ids).to eq([123_456])
  end

  context 'without automatic reference generation' do
    # rubocop:disable RSpec/AnyInstance
    before { allow_any_instance_of(described_class).to receive(:set_reference).and_return(nil) }
    # rubocop:enable RSpec/AnyInstance

    it { is_expected.to validate_presence_of(:reference) }
  end

  describe '#nomis_event_id=' do
    subject(:move) { create :move }

    context 'when nomis_event_id is not present' do
      it 'assigns the nomis_event_id to the nomis_event_ids array' do
        move.nomis_event_id = 123_456
        expect(move.nomis_event_ids).to eq([123_456])
      end
    end

    context 'when nomis_event_id is present' do
      before do
        move.nomis_event_id = 123_456
      end

      it 'assigns the nomis_event_id to the nomis_event_ids array without losing the old nomis_event_id' do
        move.nomis_event_id = 654_321
        expect(move.nomis_event_ids).to eq([123_456, 654_321])
      end
    end
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
    subject(:move) { build :move, from_location: from_location, to_location: to_location, move_type: nil }

    let(:from_location) { build :location, :police }

    before { move.valid? }

    context 'with no `to_location`' do
      let(:to_location) { nil }

      it 'sets the move type to `prison_recall` at validation time' do
        expect(move.move_type).to eq 'prison_recall'
      end
    end

    context 'with a court for it\'s `to_location`' do
      let(:to_location) { build :location, :court }

      it 'sets the move type to `court_appearance` at validation time' do
        expect(move.move_type).to eq 'court_appearance'
      end
    end

    context 'with a prison for it\'s `to_location`' do
      let(:to_location) { build :location }

      it 'sets the move type to `prison_transfer` at validation time' do
        expect(move.move_type).to eq 'prison_transfer'
      end
    end
  end

  describe '#from_nomis?' do
    subject(:move) { build :move }

    context 'with nomis_event_ids' do
      let(:nomis_event_id) { 12_345_678 }

      before { move.nomis_event_ids = [nomis_event_id] }

      it 'is truthy' do
        expect(move).to be_from_nomis
      end
    end

    context 'without nomis_event_ids' do
      before { move.nomis_event_ids = [] }

      it 'is falsy' do
        expect(move).not_to be_from_nomis
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

  describe '#served_by' do
    let(:supplier) { create :supplier }
    let!(:location) { create :location, suppliers: [supplier] }
    let!(:move_with_supplier) { create :move, from_location: location }
    let!(:move_without_supplier) { create :move }

    context 'when querying with supplier' do
      it 'returns the right move' do
        expect(described_class.served_by(supplier.id)).to include(move_with_supplier)
      end

      it 'does not return moves with no supplier' do
        expect(described_class.served_by(supplier.id)).not_to include(move_without_supplier)
      end
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

  describe '#cancel' do
    let(:move) { build(:move) }

    it 'sets the default cancellation_reason attribute to other' do
      move.cancel

      expect(move.cancellation_reason).to eq(described_class::CANCELLATION_REASON_OTHER)
    end

    it 'does not set the default cancellation_reason_comment attribute' do
      move.cancel

      expect(move.cancellation_reason_comment).to be_nil
    end

    it 'sets the cancellation_reason attribute' do
      move.cancel(reason: described_class::CANCELLATION_REASON_MADE_IN_ERROR)

      expect(move.cancellation_reason).to eq(described_class::CANCELLATION_REASON_MADE_IN_ERROR)
    end

    it 'sets the cancellation_reason_comment' do
      move.cancel(comment: 'some comment')

      expect(move.cancellation_reason_comment).to eq('some comment')
    end

    it 'sets the status to cancelled' do
      move.cancel

      expect(move.status).to eq('cancelled')
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
end
