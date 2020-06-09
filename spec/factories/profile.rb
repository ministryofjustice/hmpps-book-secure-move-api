# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    association(:person, factory: :person_without_profiles)
    first_names { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Date.new(1980, 10, 20) }
    profile_identifiers do
      [{ identifier_type: 'police_national_computer', value: 'AB/1234567' },
       { identifier_type: 'prison_number', value: 'ABCDEFG' }]
    end
    association(:ethnicity)
    association(:gender)

    trait :nomis_synced do
      latest_nomis_booking_id { 123_456_789 }
    end
  end
end
