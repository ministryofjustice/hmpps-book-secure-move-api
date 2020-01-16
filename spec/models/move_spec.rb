# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move do
  it { is_expected.to belong_to(:from_location) }
  it { is_expected.to belong_to(:to_location).optional }
  it { is_expected.to belong_to(:profile) }

  it { is_expected.to validate_presence_of(:from_location) }
  it { is_expected.to validate_presence_of(:profile) }
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class.statuses.values) }

  it 'validates presence of `to_location` if `move_type` is NOT prison_recall' do
    expect(build(:move, move_type: 'prison_transfer')).to(
      validate_presence_of(:to_location)
    )
  end

  it 'does NOT validate presence of `to_location` if `move_type` is prison_recall' do
    expect(build(:move, move_type: 'prison_recall')).not_to(
      validate_presence_of(:to_location)
    )
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
    let!(:move2) { create :move }
    let(:duplicate) {
      move.profile.moves.build(date: move.date,
                               from_location: move.from_location,
                               to_location: move.to_location)
    }

    context 'when querying for existing moves' do
      it 'finds the right move' do
        expect(duplicate.existing).to eq(move)
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
end
