# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    sequence(:key) { |x| "key_#{x}" }
    title { "HMP #{Faker::Address.city}" }
    location_type { Location::LOCATION_TYPE_PRISON }
    nomis_agency_id { 'PEI' }

    trait :with_moves do
      after(:create) do |location, _|
        create_list :move, 2, from_location: location
      end
    end

    trait :prison do
      # This is already the default
    end

    trait :court do
      sequence(:key) { |x| "court_#{x}" }
      title { "#{Faker::Address.city} Crown Court" }
      location_type { Location::LOCATION_TYPE_COURT }
      nomis_agency_id { 'GUICCT' }
    end

    trait :police do
      sequence(:key) { |x| "police_station_#{x}" }
      title { "#{Faker::Address.city} Police Station" }
      location_type { Location::LOCATION_TYPE_POLICE }
      nomis_agency_id { 'GUIPS' }
    end

    trait :hospital do
      sequence(:key) { |x| "secure_hospital_#{x}" }
      title { "#{Faker::Address.city} Secure Hospital" }
      location_type { Location::LOCATION_TYPE_HIGH_SECURITY_HOSPITAL }
      nomis_agency_id { 'GUISH' }
    end
  end
end
