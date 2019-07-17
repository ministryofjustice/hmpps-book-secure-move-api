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
        location_type: :court
      },
      {
        nomis_agency_id: 'ACI',
        key: 'aci',
        title: 'ALTCOURSE (HMP)',
        location_type: :prison
      }
    ]
  end

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(Location, :count).by(2)
    end

    it 'creates Aberdare County Court' do
      importer.call
      expect(Location.find_by(input_data[0])).to be_present
    end

    it 'creates ALTCOURSE (HMP)' do
      importer.call
      expect(Location.find_by(input_data[1])).to be_present
    end
  end

  context 'with one existing record' do
    before do
      Location.create!(input_data[0])
    end

    it 'creates only the missing item' do
      expect { importer.call }.to change(Location, :count).by(1)
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
