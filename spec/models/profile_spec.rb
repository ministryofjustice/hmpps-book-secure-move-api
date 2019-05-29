# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { is_expected.to belong_to(:person).required }
  it { is_expected.to belong_to(:ethnicity).optional }
  it { is_expected.to belong_to(:gender).optional }

  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }

  describe '#profile_attributes' do
    let!(:person) { create :person }
    let(:profile) { person.profiles.first }
    let(:profile_attributes) do
      [
        {
          description: 'test',
          comments: 'just a test',
          profile_attribute_type_id: 123,
          date: Date.civil(2019, 5, 30),
          expiry_date: Date.civil(2019, 6, 30)
        }
      ]
    end

    it 'serializes profile attributes correctly' do
      profile.profile_attributes = profile_attributes
      profile.save
      reloaded_profile = Profile.find(profile.id)
      expect(reloaded_profile.profile_attributes&.first&.as_json).to eql(profile_attributes.first)
    end

    it 'deserializes profile attributes to an array of ProfileAttribute objects' do
      profile.profile_attributes = profile_attributes
      expect(profile.profile_attributes.first).to be_a(Profile::ProfileAttribute)
    end
  end
end
