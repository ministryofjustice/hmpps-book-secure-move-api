# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location do
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to have_many(:supplier_locations) }
  it { is_expected.to have_many(:suppliers).through(:supplier_locations) }
  it { is_expected.to have_many(:moves_from) }
  it { is_expected.to have_many(:moves_to) }
  it { is_expected.to have_many(:populations) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:location_type) }
  it { is_expected.to define_enum_for(:location_type).backed_by_column_of_type(:string) }

  context 'when location is a court' do
    subject(:location) { build :location, :court }

    it { expect(location.detained?).to be false }
    it { expect(location.not_detained?).to be true }
  end

  context 'when location is a police custody unit' do
    subject(:location) { build :location, :police }

    it { expect(location.detained?).to be false }
    it { expect(location.not_detained?).to be true }
  end

  context 'when location is a prison' do
    subject(:location) { build :location }

    it { expect(location.detained?).to be true }
    it { expect(location.not_detained?).to be false }
  end

  context 'when location is a secure childrens hospital' do
    subject(:location) { build :location, :sch }

    it { expect(location.detained?).to be true }
    it { expect(location.not_detained?).to be false }
  end

  context 'when location is a secure training centre' do
    subject(:location) { build :location, :stc }

    it { expect(location.detained?).to be true }
    it { expect(location.not_detained?).to be false }
  end

  describe '#for_feed' do
    subject(:location) { create(:location) }

    context 'when a prefix is supplied' do
      let(:prefix) { 'from' }
      let(:expected_json) do
        {
          'from_location_type' => location.location_type,
          'from_location' => location.nomis_agency_id,
        }
      end

      it 'generates a feed document' do
        expect(location.for_feed(prefix:)).to include_json(expected_json)
      end
    end

    context 'when a prefix is not supplied' do
      let(:expected_json) do
        {
          'location_type' => location.location_type,
          'location' => location.nomis_agency_id,
        }
      end

      it 'generates a feed document' do
        expect(location.for_feed).to include_json(expected_json)
      end
    end
  end

  describe '#geocode' do
    let(:location) { build(:location, :with_address) }
    let(:valid_latitude) { 51.4992813 }
    let(:valid_longitude) { -0.1363143 }
    let(:valid_coordinates) { [valid_latitude, valid_longitude] }
    let(:unknown_coordinates) { [nil, nil] }

    before do
      allow(location).to receive(:geocode) do
        location.latitude = valid_latitude
        location.longitude = valid_longitude
        valid_coordinates
      end
    end

    it 'automatically geocodes valid postcode on save' do
      location.save!
      expect(location).to have_received(:geocode)
      expect(location.coordinates).to eq(valid_coordinates)
    end

    it 'does not geocode discarded locations' do
      location.discard
      expect(location).not_to have_received(:geocode)
      expect(location.coordinates).to eq(unknown_coordinates)
    end

    it 'does not geocode if postcode not present' do
      location.postcode = nil
      location.save!
      expect(location).not_to have_received(:geocode)
      expect(location.coordinates).to eq(unknown_coordinates)
    end

    it 'does not geocode again if postcode has not changed and was previously geocoded' do
      location.save!
      location.reload
      location.save!
      expect(location).to have_received(:geocode).once
    end

    it 'automatically geocodes again if postcode has changed' do
      location.save!
      location.postcode = 'B2 1JP'
      location.save!
      expect(location).to have_received(:geocode).twice
    end

    it 'automatically geocodes again if coordinates are missing' do
      location.save!
      location.longitude = nil
      location.latitude = nil
      location.save!
      expect(location).to have_received(:geocode).twice
    end
  end

  describe 'extradition_capable' do
    let(:location) { build(:location) }

    it 'has an extradition_capable field' do
      location.extradition_capable = true
      location.save!
      expect(location.reload.extradition_capable).to be(true)
    end
  end
end
