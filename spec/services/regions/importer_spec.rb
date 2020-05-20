# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Regions::Importer do
  subject(:importer) { described_class.new(input_data) }

  let!(:linked_location1) { create :location, nomis_agency_id: 'FOO' }
  let!(:linked_location2) { create :location, nomis_agency_id: 'BAR' }
  let!(:unlinked_location) { create :location, nomis_agency_id: 'BAZ' }

  let(:input_data) do
    {
      '1': {
        name: 'First region',
        locations: %w[FOO BAR],
      },
      '2A': {
        name: 'Second region',
        locations: %w[FOO BUZZ],
      },
    }
  end

  let(:region1) { Region.find_by(key: '1') }
  let(:region2) { Region.find_by(key: '2A') }

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Region, :count).by(2)
    end

    it 'populates correct name' do
      importer.call

      expect(region1.name).to eq 'First region'
    end

    it 'links to correct locations' do
      importer.call

      expect(region1.locations.map(&:nomis_agency_id)).to match_array %w[FOO BAR]
    end

    it 'does not link to missing locations' do
      importer.call

      expect(region2.locations.map(&:nomis_agency_id)).to match %w[FOO]
    end
  end

  context 'with one existing record' do
    before do
      create(:region, key: '1', name: 'First region')
    end

    it 'creates only the missing items' do
      expect { importer.call }.to change(Region, :count).by(1)
    end
  end

  context 'with one existing record with the wrong name' do
    let!(:existing) { create(:region, key: '2A', name: 'Wrong', locations: [unlinked_location]) }

    it 'updates the title of the existing record' do
      importer.call
      expect(existing.reload.name).to eq 'Second region'
    end

    it 'updates links to correct locations' do
      importer.call
      expect(existing.reload.locations.map(&:nomis_agency_id)).to match %w[FOO]
    end
  end
end
