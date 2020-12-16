require 'rails_helper'

RSpec.describe Population do
  it { is_expected.to belong_to(:location) }

  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:operational_capacity) }
  it { is_expected.to validate_presence_of(:usable_capacity) }
  it { is_expected.to validate_presence_of(:unlock) }
  it { is_expected.to validate_presence_of(:bedwatch) }
  it { is_expected.to validate_presence_of(:overnights_in) }
  it { is_expected.to validate_presence_of(:overnights_out) }
  it { is_expected.to validate_presence_of(:out_of_area_courts) }
  it { is_expected.to validate_presence_of(:discharges) }
  it { is_expected.to validate_numericality_of(:operational_capacity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:usable_capacity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:unlock).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:bedwatch).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:overnights_in).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:overnights_out).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:out_of_area_courts).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:discharges).is_greater_than_or_equal_to(0) }

  it 'validates uniqueness of date per location' do
    population = build(:population)
    expect(population).to validate_uniqueness_of(:date).scoped_to(:location_id)
  end

  describe '#moves_from' do
    it 'includes non-cancelled prison transfer moves from same location on same date' do
      location = create(:location, :prison)
      move = create(:move, :prison_transfer, date: Date.today, from_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_from).to contain_exactly(move)
    end

    it 'excludes cancelled moves' do
      location = create(:location, :prison)
      create(:move, :prison_transfer, :cancelled, date: Date.today, from_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_from).to be_empty
    end

    it 'excludes other types of move' do
      location = create(:location, :prison)
      create(:move, :court_appearance, date: Date.today, from_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_from).to be_empty
    end

    it 'excludes moves on a different date' do
      location = create(:location, :prison)
      create(:move, :prison_transfer, date: Date.tomorrow, from_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_from).to be_empty
    end

    it 'excludes moves from a different location' do
      location = create(:location, :prison)
      create(:move, :prison_transfer, date: Date.today)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_from).to be_empty
    end
  end

  describe '#moves_to' do
    it 'includes non-cancelled prison transfer moves to same location on same date' do
      location = create(:location, :prison)
      move = create(:move, :prison_transfer, date: Date.today, to_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_to).to contain_exactly(move)
    end

    it 'excludes cancelled moves' do
      location = create(:location, :prison)
      create(:move, :prison_transfer, :cancelled, date: Date.today, to_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_to).to be_empty
    end

    it 'excludes other types of move' do
      location = create(:location, :prison)
      create(:move, :prison_recall, date: Date.today, to_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_to).to be_empty
    end

    it 'excludes moves on a different date' do
      location = create(:location, :prison)
      create(:move, :prison_transfer, date: Date.tomorrow, to_location: location)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_to).to be_empty
    end

    it 'excludes moves from a different location' do
      location = create(:location, :prison)
      create(:move, :prison_transfer, date: Date.today)
      population = create(:population, date: Date.today, location: location)

      expect(population.moves_to).to be_empty
    end
  end

  describe '#free_spaces' do
    it 'subtracts unavailable space from usable capacity' do
      population = create(:population, usable_capacity: 10, unlock: 1, bedwatch: 1, overnights_in: 1, overnights_out: 0, out_of_area_courts: 0, discharges: 0)
      expect(population.free_spaces).to eq(7)
    end

    it 'adds available space to usable capacity' do
      population = create(:population, usable_capacity: 10, unlock: 0, bedwatch: 0, overnights_in: 0, overnights_out: 1, out_of_area_courts: 1, discharges: 1)
      expect(population.free_spaces).to eq(13)
    end

    it 'subtracts transfers in from usable capacity' do
      move = create(:move, :prison_transfer)
      population = create(:population, location: move.to_location, date: move.date, usable_capacity: 10, unlock: 0, bedwatch: 0, overnights_in: 0, overnights_out: 0, out_of_area_courts: 0, discharges: 0)
      expect(population.free_spaces).to eq(9)
    end

    it 'adds transfers out to usable capacity' do
      move = create(:move, :prison_transfer)
      population = create(:population, location: move.from_location, date: move.date, usable_capacity: 10, unlock: 0, bedwatch: 0, overnights_in: 0, overnights_out: 0, out_of_area_courts: 0, discharges: 0)
      expect(population.free_spaces).to eq(11)
    end
  end

  describe '.save_uniquely!' do
    it 'saves population if no errors' do
      population = build(:population)
      population.save_uniquely!

      expect(population).to be_persisted
    end

    it 'raises exception with existing populations for the same date and location' do
      existing_population = create(:population)
      new_population = build(:population, location: existing_population.location, date: existing_population.date)

      expect { new_population.save_uniquely! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(new_population.errors[:date]).to contain_exactly('has already been taken')
    end
  end

  describe '.free_spaces_date_range' do
    let!(:prison1) { create(:location, :prison) }
    let!(:prison2) { create(:location, :prison) }
    let!(:move1) { create(:move, :prison_transfer, from_location: prison1, date: Date.yesterday) }
    let!(:move2) { create(:move, :prison_transfer, from_location: prison1, date: Date.yesterday) }
    let!(:move3) { create(:move, :prison_transfer, to_location: prison1, date: Date.yesterday) }
    let!(:move4) { create(:move, :prison_transfer, from_location: prison1, date: Date.today) }
    let!(:move5) { create(:move, :prison_transfer, to_location: prison2, date: Date.today) }
    let!(:move6) { create(:move, :prison_transfer, from_location: prison1, date: Date.tomorrow) }
    let!(:population1) { create(:population, location: prison1, date: Date.today) } # Included
    let!(:population2) { create(:population, location: prison2, date: Date.today) } # Included
    let!(:population3) { create(:population, location: prison1, date: Date.tomorrow) } # Included
    let!(:population4) { create(:population, location: prison2, date: Date.tomorrow) } # Included
    let!(:population5) { create(:population, location: prison1, date: Date.today - 2) } # Falls outside scope of dates, so not included
    let(:date_range) { (Date.yesterday..Date.tomorrow) }
    let(:locations) { Location.where(id: [prison1.id, prison2.id]) }

    let(:expected_hash) do
      {
        prison1.id => [
          {
            # No population data for yesterday
            free_spaces: nil,
            id: nil,
            transfers_in: 1,
            transfers_out: 2,
          },
          {
            free_spaces: population1.free_spaces,
            id: population1.id,
            transfers_in: 0,
            transfers_out: 1,
          },
          {
            free_spaces: population3.free_spaces,
            id: population3.id,
            transfers_in: 0,
            transfers_out: 1,
          },
        ],
        prison2.id => [
          {
            # No population data for yesterday
            free_spaces: nil,
            id: nil,
            transfers_in: 0,
            transfers_out: 0,
          },
          {
            free_spaces: population2.free_spaces,
            id: population2.id,
            transfers_in: 1,
            transfers_out: 0,
          },
          {
            free_spaces: population4.free_spaces,
            id: population4.id,
            transfers_in: 0,
            transfers_out: 0,
          },
        ],
      }
    end

    it 'returns hashed array of free space details by location id' do
      expect(described_class.free_spaces_date_range(locations, date_range)).to eq(expected_hash)
    end
  end
end
