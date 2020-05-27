# frozen_string_literal: true

require 'rails_helper'

# TODO: Remove this once we've migrated all profile attributes to a person and are updating these attributes dynamically
RSpec.describe PersonPopulator do
  subject(:populator) { described_class.new(person, profile) }

  let(:profile) do
    create(
      :profile,
      person: person,
      ethnicity: ethnicity,
      gender: gender,
      first_names: 'Randi',
      last_name: 'Vandervort',
      date_of_birth: Date.parse('1987-05-04'),
      gender_additional_information: 'foo',
      latest_nomis_booking_id: 1,
      profile_identifiers: profile_identifiers,
    )
  end
  let(:profile_identifiers) do
    [
      {
        identifier_type: 'police_national_computer',
        value: 'NPD4X0/3D',
      },
      {
        identifier_type: 'criminal_records_office',
        value: 'CRO/74506',
      },
      {
        identifier_type: 'prison_number',
        value: 'D39067ZZ',
      },
      {
        identifier_type: 'niche_reference',
        value: 'NI/52377',
      },
      {
        identifier_type: 'athena_reference',
        value: 'AT/72317',
      },
    ]
  end

  let(:person) { create(:person) }
  let(:ethnicity) { create(:ethnicity) }
  let(:gender) { create(:gender) }

  describe '#call' do
    let(:populated_attributes) do
      %w[
        first_names
        last_name
        date_of_birth
        gender_additional_information
        latest_nomis_booking_id
        ethnicity_id
        gender_id
        prison_number
        criminal_records_office
        police_national_computer
      ]
    end
    let(:expected_attributes) do
      {
        'first_names' => 'Randi',
        'last_name' => 'Vandervort',
        'date_of_birth' => Date.parse('1987-05-04'),
        'gender_additional_information' => 'foo',
        'latest_nomis_booking_id' => 1,
        'ethnicity_id' => ethnicity.id,
        'gender_id' => gender.id,
        'prison_number' => 'D39067ZZ',
        'criminal_records_office' => 'CRO/74506',
        'police_national_computer' => 'NPD4X0/3D',
      }
    end

    it 'populates a person with the correct attributes' do
      populator.call

      expect(person.slice(*populated_attributes)).to eq(expected_attributes)
    end
  end
end
