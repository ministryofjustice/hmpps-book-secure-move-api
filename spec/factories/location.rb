# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    sequence(:key) { |x| "key_#{x}" }
    title { "HMP #{Faker::Address.city}" }
    location_type { Location::LOCATION_TYPE_PRISON }
    nomis_agency_id { 'PEI' }

    trait :with_moves do
      after(:create) do |location, _|
        create_list :move, 10, from_location: location
      end
    end

    trait :with_supplier do
      after(:create) do |location, _|
        create :supplier, locations: [location]
      end
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
  end
end
