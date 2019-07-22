# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifierTypes::Importer do
  subject(:importer) { described_class.new }

  context 'with no existing records' do
    it 'creates all the input items' do
      expect { importer.call }.to change(IdentifierType, :count).by(3)
    end

    it 'creates PNC ID' do
      importer.call
      expect(IdentifierType.find_by(id: 'police_national_computer', title: 'PNC ID')).to be_present
    end

    it 'creates Prisoner No.' do
      importer.call
      expect(IdentifierType.find_by(id: 'prison_number', title: 'Prisoner No')).to be_present
    end

    it 'creates CRO No' do
      importer.call
      expect(IdentifierType.find_by(id: 'criminal_records_office', title: 'CRO No')).to be_present
    end
  end

  context 'with one existing record' do
    before do
      IdentifierType.create!(id: 'prison_number', title: 'Prisoner No')
    end

    it 'creates only the missing item' do
      expect { importer.call }.to change(IdentifierType, :count).by(2)
    end
  end

  context 'with one existing record with the wrong title' do
    let!(:prison_number) do
      IdentifierType.create!(id: 'prison_number', title: 'Prison')
    end

    it 'updates the title of the existing record' do
      importer.call
      expect(prison_number.reload.title).to eq 'Prisoner No'
    end
  end
end
