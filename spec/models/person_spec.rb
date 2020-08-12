# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person do
  subject(:person) { create(:person) }

  it { is_expected.to have_many(:profiles) }
  it { is_expected.to have_many(:moves) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }

  it 'has an audit' do
    expect(person.versions.map(&:event)).to eq(%w[create update])
  end

  it 'gets an image attached' do
    person.attach_image('image_data')

    expect(person.image.attached?).to be true
    expect(person.image.filename).to eq "#{person.id}.jpg"
  end

  describe '#police_national_computer' do
    subject!(:person) { create(:person, police_national_computer: 'FLIBBLE') }

    it 'is case insensitive' do
      expect(described_class.where(police_national_computer: 'flibble')).to include(person)
    end
  end

  describe '#criminal_records_office' do
    subject!(:person) { create(:person, criminal_records_office: 'FLIBBLE') }

    it 'is case insensitive' do
      expect(described_class.where(criminal_records_office: 'flibble')).to include(person)
    end
  end

  describe '#prison_number' do
    subject!(:person) { create(:person, prison_number: 'FLIBBLE') }

    it 'is case insensitive' do
      expect(described_class.where(prison_number: 'flibble')).to include(person)
    end
  end

  # TODO: Remove nomis_prison_number once we remove v1 from our system
  describe '#nomis_prison_number' do
    subject!(:person) { create(:person, nomis_prison_number: 'FLIBBLE') }

    it 'is case insensitive' do
      expect(described_class.where(nomis_prison_number: 'flibble')).to include(person)
    end
  end

  describe '#for_feed' do
    subject(:person) { create(:person) }

    let(:expected_json) do
      {
        'id' => person.id,
        'created_at' => be_a(Time),
        'updated_at' => be_a(Time),
        'criminal_records_office' => person.criminal_records_office,
        'nomis_prison_number' => person.nomis_prison_number,
        'police_national_computer' => person.police_national_computer,
        'prison_number' => person.prison_number,
        'latest_nomis_booking_id' => person.latest_nomis_booking_id,
        'age' => person.age,
      }
    end

    it 'generates a feed document' do
      expect(person.for_feed).to include_json(expected_json)
    end
  end

  describe '.updated_at_range' do
    let(:updated_at_from) { Time.zone.now.beginning_of_day - 1.day }
    let(:updated_at_to) { Time.zone.now.end_of_day - 1.day }

    let!(:before_start_person) { create(:person) }
    let!(:on_start_person) { create(:person) }
    let!(:on_end_person) {  create(:person) }
    let!(:after_end_person) { create(:person) }

    it 'returns the expected persons' do
      # NB: Associations touch parents in factories so updated_at needs to be patched
      # after all resources have been created
      before_start_person.update(updated_at: updated_at_from - 1.second)
      on_start_person.update(updated_at: updated_at_from)
      on_end_person.update(updated_at: updated_at_to)
      after_end_person.update(updated_at: updated_at_to + 1.second)

      actual_persons = described_class.updated_at_range(
        updated_at_from,
        updated_at_to,
      )
      expect(actual_persons).to eq([on_start_person, on_end_person])
    end
  end
end
