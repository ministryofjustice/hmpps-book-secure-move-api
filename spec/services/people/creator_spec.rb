# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::Creator do
  subject(:creator) { described_class.new(params) }

  let(:params) do
    {
      type: 'people',
      attributes: {
        first_names: 'Bob',
        last_name: 'Roberts',
        date_of_birth: Date.civil(1980, 1, 1),
        criminal_records_office: nil,
        prison_number: nil,
        police_national_computer: nil,
      },
    }
  end

  let(:new_profile) { Profile.last }
  let(:new_person) { Person.last }

  context 'with valid input params' do
    let!(:result) { creator.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'new profile to be accessible' do
      expect(creator.profile).to be_persisted
    end

    it 'creates a new Profile' do
      expect(new_profile).to be_present
    end

    it 'sets the correct Person attibutes' do
      expect(new_person.attributes.with_indifferent_access).to include(params[:attributes])
    end

    it 'creates a new Person' do
      expect(new_person).to be_present
    end

    it 'associates Person and Profile' do
      expect(new_profile.person).to eql new_person
    end
  end

  context 'with valid input params including relationships' do
    let(:ethnicity) { create :ethnicity }
    let(:gender) { create :gender }
    let(:params) do
      {
        type: 'people',
        attributes: {
          first_names: 'Bob',
          last_name: 'Roberts',
          date_of_birth: Date.civil(1980, 1, 1),
        },
        relationships: {
          ethnicity: {
            data: {
              id: ethnicity.id,
              type: 'ethnicities',
            },
          },
          gender: {
            data: {
              id: gender.id,
              type: 'genders',
            },
          },
        },
      }
    end

    let!(:result) { creator.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'new profile to be accessible' do
      expect(creator.profile).to be_persisted
    end

    it 'sets the correct Person ethnicity' do
      expect(new_person.ethnicity_id).to eql ethnicity.id
    end

    it 'sets the correct Person gender' do
      expect(new_person.gender_id).to eql gender.id
    end
  end

  context 'with identifiers' do
    let(:params) do
      {
        type: 'people',
        attributes: {
          first_names: 'Bob',
          last_name: 'Roberts',
          date_of_birth: Date.civil(1980, 1, 1),
          identifiers: [
            { identifier_type: 'police_national_computer', value: 'ABC123' },
            { identifier_type: 'prison_number', value: 'XYZ987' },
          ],
        },
      }
    end

    let!(:result) { creator.call }

    it 'sets the identifiers for the Person' do
      identifiers = new_person
        .attributes
        .with_indifferent_access
        .slice(*Person::IDENTIFIER_TYPES)

      expect(identifiers).to eq(
        'criminal_records_office' => nil,
        'police_national_computer' => 'ABC123',
        'prison_number' => 'XYZ987',
      )
    end
  end
end
