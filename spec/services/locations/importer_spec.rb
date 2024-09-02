# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Importer do
  subject(:importer) { described_class.new(input_data, location_details) }

  let(:input_data) do
    [
      {
        nomis_agency_id: 'ABDRCT',
        key: 'abdrct',
        title: 'Aberdare County Court',
        location_type: :court,
        can_upload_documents: false,
      },
      {
        nomis_agency_id: 'ACI',
        key: 'aci',
        title: 'ALTCOURSE (HMP)',
        location_type: :prison,
        can_upload_documents: false,
      },
      {
        nomis_agency_id: 'SCH1',
        key: 'sch_one',
        title: 'A Test SCH',
        location_type: :secure_childrens_home,
        can_upload_documents: true,
      },
      {
        nomis_agency_id: 'STC1',
        key: 'stc_one',
        title: 'A Test STC',
        location_type: :secure_training_centre,
        can_upload_documents: true,
      },
      {
        nomis_agency_id: 'HOSP1',
        key: 'arkham',
        title: 'Arkham Asylum',
        location_type: :high_security_hospital,
        can_upload_documents: false,
      },
      {
        nomis_agency_id: 'FOO1',
        key: 'bar',
        title: "Don't import me",
        location_type: 'FOO',
        can_upload_documents: false,
      },
      {
        nomis_agency_id: 'CUSTARD',
        key: 'custard',
        title: 'Heathrow Custody Suite (changed name)',
        location_type: :police,
        can_upload_documents: false,
      },
    ]
  end

  let(:location_details) do
    {
      'ACI' => {
        premise: 'HMP ALTCOURSE',
        locality: 'Fazakerley',
        city: 'Liverpool',
        country: 'England',
        postcode: 'L9 7LH',
      },
      'SCH1' => {
        premise: 'The Building',
        city: 'Springfield',
        postcode: 'ZZ99 9ZZ',
      },
    }
  end

  # Avoid real calls to external geocoding API
  Geocoder.configure(lookup: :test, ip_lookup: :test)
  Geocoder::Lookup::Test.set_default_stub(
    [{ 'coordinates' => [] }],
  )
  Geocoder::Lookup::Test.add_stub(
    'L9 7LH', [{ 'coordinates' => [53.4614425, -2.9357489] }]
  )

  context 'with no existing records' do
    it 'creates all the supported input items' do
      expect { importer.call }.to change(Location, :count).by(6)
    end

    it 'creates all the known location types' do
      importer.call

      input_data[0..4].each do |data|
        expect(Location.find_by(data)).to be_present
      end
    end

    it 'populates address details when provided' do
      importer.call

      expect(Location.find_by(nomis_agency_id: 'ACI')).to have_attributes(
        premise: 'HMP ALTCOURSE',
        locality: 'Fazakerley',
        city: 'Liverpool',
        country: 'England',
        postcode: 'L9 7LH',
      )
    end

    it 'geocodes valid postcode when provided' do
      importer.call

      expect(Location.find_by(nomis_agency_id: 'ACI')).to have_attributes(
        latitude: 53.4614425,
        longitude: -2.9357489,
      )
    end

    it 'does not geocode invalid postcode' do
      importer.call

      expect(Location.find_by(nomis_agency_id: 'SCH1')).to have_attributes(
        latitude: nil,
        longitude: nil,
      )
    end

    it 'does not import unknown location types' do
      importer.call
      expect(Location.find_by(input_data[5])).not_to be_present
    end

    it 'does not populate missing address details' do
      importer.call

      expect(Location.find_by(nomis_agency_id: 'ABDRCT')).to have_attributes(
        premise: nil,
        locality: nil,
        city: nil,
        country: nil,
        postcode: nil,
      )
    end

    it 'returns a list of new locations' do
      importer.call
      expect(importer.added_locations).to match_array(%w[ABDRCT ACI CUSTARD FOO1 HOSP1 SCH1 STC1])
    end
  end

  context 'with one existing record with no changes' do
    before do
      Location.create!(input_data[0])
    end

    it 'creates only the missing items' do
      expect { importer.call }.to change(Location, :count).by(5)
    end

    it 'does not return the existing location in the list of updated records' do
      importer.call
      expect(importer.updated_locations).to be_empty
    end
  end

  context 'with one existing record with the wrong title' do
    let!(:court) do
      Location.create!(nomis_agency_id: 'ABDRCT', key: 'abdrct', title: 'Axxxx Cxxxx Court', location_type: :court)
    end

    it 'updates the title of the existing location' do
      importer.call
      expect(court.reload.title).to eq 'Aberdare County Court'
    end

    it 'returns the existing location in the list of updated records' do
      importer.call
      expect(importer.updated_locations).to match_array(%w[ABDRCT])
    end
  end

  context 'with an existing record which should be disabled' do
    let!(:court) do
      Location.create!(nomis_agency_id: 'OLDEBAILEY', key: 'oldebailey', title: 'Ye Olde Bailey', location_type: :court)
    end

    it 'updates the disabled_at attribute of the existing location' do
      importer.call
      expect(court.reload.disabled_at).to be_present
    end

    it 'returns the existing location in the list of disabled records' do
      importer.call
      expect(importer.disabled_locations).to match_array(%w[OLDEBAILEY])
    end
  end

  context 'with an existing disabled location which should not be disabled' do
    let!(:court) do
      Location.create!(input_data[0].merge(disabled_at: Time.zone.now))
    end

    it 'updates the disabled_at attribute of the existing record' do
      importer.call
      expect(court.reload.disabled_at).not_to be_present
    end

    it 'returns the existing record in the list of updated records' do
      importer.call
      expect(importer.disabled_locations).to be_empty
      expect(importer.updated_locations).to match_array(%w[ABDRCT])
    end
  end

  context 'with an existing extradition_capable location' do
    let!(:custody_suite) do
      Location.create!(input_data[6].merge(extradition_capable: true, title: 'Heathrow (old name)'))
    end

    it 'does not change the extradition_capable attribute of the existing record' do
      importer.call
      expect(custody_suite.reload.extradition_capable).to be(true)
    end

    it 'returns the existing record in the list of updated records' do
      importer.call
      expect(importer.disabled_locations).to be_empty
      expect(importer.updated_locations).to match_array(%w[CUSTARD])
    end
  end
end
