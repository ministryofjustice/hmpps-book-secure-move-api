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
end
