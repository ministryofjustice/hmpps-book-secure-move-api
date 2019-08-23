# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Importer do
  subject(:importer) { described_class.new(input_data) }

  let(:input_data) do
    {
      prison_number: 'G3239GV',
      last_name: 'ABBELLA',
      first_name: 'AVEILKE',
      middle_names: 'EMMANDA',
      date_of_birth: '1965-10-15',
      aliases: nil,
      pnc_number: '82/18053V',
      cro_number: '018053/82G',
      gender: 'F',
      ethnicity: 'White: Eng./Welsh/Scot./N.Irish/British',
      nationalities: 'British'
    }
  end

  let!(:ethnicity) { create(:ethnicity, title: 'White: Eng./Welsh/Scot./N.Irish/British') }
  let!(:gender) { create(:gender, nomis_code: 'F') }

  context 'with no existing records' do
    it 'creates a person' do
      expect { importer.call }.to change(Person, :count).by(1)
    end

    it 'sets person nomis_prison_number' do
      importer.call
      expect(Person.find_by(nomis_prison_number: 'G3239GV')).to be_present
    end

    it 'creates a profile' do
      expect { importer.call }.to change(Profile, :count).by(1)
    end

    it 'sets profile fields' do
      importer.call
      expect(Profile.first.slice(:last_name, :first_names, :date_of_birth)).to eq(
        'last_name' => 'ABBELLA', 'first_names' => 'AVEILKE EMMANDA', 'date_of_birth' => Date.parse('1965-10-15')
      )
    end

    it 'sets profile identifiers' do
      importer.call
      expect(Profile.first.profile_identifiers.map(&:value))
        .to eq(['82/18053V', 'G3239GV', '018053/82G'])
    end
  end

  context 'with one existing person' do
    before do
      Person.create!(nomis_prison_number: 'G3239GV')
    end

    it 'does not create a person' do
      expect { importer.call }.to change(Person, :count).by(0)
    end

    it 'creates only the profile' do
      expect { importer.call }.to change(Profile, :count).by(1)
    end
  end

  context 'with one existing person and profile' do
    let!(:person) { Person.create(nomis_prison_number: 'G3239GV') }
    let!(:profile) { create(:profile, person: person, last_name: 'BLOGS') }

    it 'does not create a person' do
      expect { importer.call }.to change(Person, :count).by(0)
    end

    it 'does not create a profile' do
      expect { importer.call }.to change(Profile, :count).by(0)
    end

    it 'updates fields on the profile' do
      importer.call
      expect(Profile.first.last_name).to eq 'ABBELLA'
    end
  end
end
