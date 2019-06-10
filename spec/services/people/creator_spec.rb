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
        date_of_birth: Date.civil(1980, 1, 1)
      }
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

    it 'sets the correct Profile attibutes' do
      expect(new_profile.attributes.with_indifferent_access).to include(params[:attributes])
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
          date_of_birth: Date.civil(1980, 1, 1)
        },
        relationships: {
          ethnicity: {
            data: {
              id: ethnicity.id,
              type: 'ethnicities'
            }
          },
          gender: {
            data: {
              id: gender.id,
              type: 'genders'
            }
          }
        }
      }
    end

    let!(:result) { creator.call }

    it 'result to be true' do
      expect(result).to be true
    end

    it 'new profile to be accessible' do
      expect(creator.profile).to be_persisted
    end

    it 'sets the correct Profile ethnicity' do
      expect(new_profile.ethnicity_id).to eql ethnicity.id
    end

    it 'sets the correct Profile gender' do
      expect(new_profile.gender_id).to eql gender.id
    end
  end

  context 'with missing required attributes' do
    let(:params) do
      {
        type: 'people',
        attributes: { first_names: 'Bob' }
      }
    end

    it 'raises an error' do
      expect { creator.call }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'makes validation errors available via exception' do
      creator.call
    rescue ActiveRecord::RecordInvalid => e
      expect(e.record.errors.messages).to include(last_name: ["can't be blank"])
    end
  end
end
