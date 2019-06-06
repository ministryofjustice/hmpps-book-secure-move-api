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

  context 'with valid input params' do
    before { creator.call }

    let(:new_profile) { Profile.last }
    let(:new_person) { Person.last }

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
end
