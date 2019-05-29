# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Profile, type: :model do
  it { is_expected.to belong_to(:person).required }
  it { is_expected.to belong_to(:ethnicity).optional }
  it { is_expected.to belong_to(:gender).optional }

  it { is_expected.to validate_presence_of(:person) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:first_names) }

  it 'serializes profile attributes correctly' do
    person = create :person
    profile = person.profiles.first
    profile.profile_attributes = [
      {
        description: 'test',
        comments: 'just a test',
        profile_attribute_type_id: 123,
        date: Date.civil(2019, 5, 30),
        expiry_date: Date.civil(2019, 6, 30)
      }
    ]
    profile.save
    profile.profile_attributes
    profile = Profile.find(profile.id)
    expect(profile.profile_attributes&.first&.as_json).to eql(
      description: 'test',
      comments: 'just a test',
      profile_attribute_type_id: 123,
      date: Date.civil(2019, 5, 30),
      expiry_date: Date.civil(2019, 6, 30)
    )
  end
end
