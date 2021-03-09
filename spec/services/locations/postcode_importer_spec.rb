# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::PostcodeImporter do
  subject(:importer) { described_class.new(input_data) }

  let!(:court_location) { create(:location, :court, nomis_agency_id: 'CRT') }
  let!(:prison_location) { create(:location, :prison, nomis_agency_id: 'ACI') }
  let!(:disabled_location) { create(:location, :prison, :inactive, nomis_agency_id: 'DIS') }

  let(:input_data) do
    [
      {
        'nomis_agency_id' => 'CRT',
        'postcode' => 'SW1H 9AJ',
      },
      {
        'nomis_agency_id' => 'ACI',
        'postcode' => 'L9 7LH',
      },
      {
        'nomis_agency_id' => 'DIS',
        'postcode' => 'SW1H 9AJ',
      },
      {
        'nomis_agency_id' => 'UNKNOWN',
      },
    ]
  end

  # Avoid real calls to external geocoding API
  Geocoder.configure(lookup: :test, ip_lookup: :test)
  Geocoder::Lookup::Test.set_default_stub(
    [{ 'coordinates' => [] }],
  )
  Geocoder::Lookup::Test.add_stub(
    'SW1H 9AJ', [{ 'coordinates' => [51.4992813, -0.1363143] }]
  )

  context 'when importing postcodes' do
    it 'populates postcode and geocodes existing non-prison locations' do
      importer.call
      expect(court_location.reload).to have_attributes({
        postcode: 'SW1H 9AJ',
        latitude: 51.4992813,
        longitude: -0.1363143,
      })
    end

    it 'ignores unknown, disabled and prison locations' do
      importer.call
      expect(importer.ignored_locations).to contain_exactly('ACI', 'DIS', 'UNKNOWN')
    end
  end
end
