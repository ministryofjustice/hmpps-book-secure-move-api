# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    association :person, factory: :person_without_profile
    first_names { 'Bob' }
    last_name { 'Roberts' }
    date_of_birth { Date.new(1980, 10, 20) }
    profile_identifiers { [{ identifier_type: 'police_national_computer', value: 'AB/1234567' }] }
    association(:ethnicity)
    association(:gender)
  end
end
