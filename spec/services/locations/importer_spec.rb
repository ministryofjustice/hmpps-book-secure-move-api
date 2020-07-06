# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::Importer do
  subject(:importer) { described_class.new(input_data) }

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
        location_type: 'SCH',
        can_upload_documents: true,
      },
      {
        nomis_agency_id: 'STC1',
        key: 'stc_one',
        title: 'A Test STC',
        location_type: 'STC',
        can_upload_documents: true,
      },
      {
        nomis_agency_id: 'HOSP1',
        key: 'arkham',
        title: 'Arkham Asylum',
        location_type: 'HSHOSP',
        can_upload_documents: false,
      },
      { nomis_agency_id: 'FOO1',
        key: 'bar',
        title: "Don't import me",
        location_type: 'FOO',
        can_upload_documents: false },
    ]
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Location, :count).by(6)
    end

    it 'creates all the locations' do
      importer.call

      input_data.each do |data|
        expect(Location.find_by(data)).to be_present
      end
    end
  end

  context 'with one existing record' do
    before do
      Location.create!(input_data[0])
    end

    it 'creates only the missing items' do
      expect { importer.call }.to change(Location, :count).by(5)
    end
  end

  context 'with one existing record with the wrong title' do
    let!(:court) do
      Location.create!(nomis_agency_id: 'ABDRCT', key: 'abdrct', title: 'Axxxx Cxxxx Court', location_type: :court)
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(court.reload.title).to eq 'Aberdare County Court'
    end
  end
end
