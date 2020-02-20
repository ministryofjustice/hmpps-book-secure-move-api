# frozen_string_literal: true

FactoryBot.define do
  factory :person_without_profiles, class: Person
  factory :profile do
    association(:person, factory: :person_without_profiles)
    first_names { 'Bob' }
    last_name { 'Roberts' }
    date_of_birth { Date.new(1980, 10, 20) }
    profile_identifiers {
      [{ identifier_type: 'police_national_computer', value: 'AB/1234567' },
       { identifier_type: 'prison_number', value: 'ABCDEFG' }]
    }
    association(:ethnicity)
    association(:gender)
  end
end
