# frozen_string_literal: true

FactoryBot.define do
  factory :profile_attribute do
    description { 'Needs to wear spectacles to read a book' }
    association(:profile)
    association(:profile_attribute_type)
  end
end
