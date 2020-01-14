# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    key { 'hmp_pentonville' }
    title { 'HMP Pentonville' }
    location_type { Location::LOCATION_TYPE_PRISON }
    nomis_agency_id { 'PEI' }

    trait :with_moves do
      after(:create) do |location, _|
        create_list :move, 10, from_location: location
      end
    end

    trait :court do
      key { 'guildford_crown_court' }
      title { 'Guildford Crown Court' }
      location_type { Location::LOCATION_TYPE_COURT }
      nomis_agency_id { 'GUICCT' }
    end

    trait :police do
      key { 'guildford_police_station' }
      title { 'Guildford Police Station' }
      location_type { Location::LOCATION_TYPE_POLICE }
      nomis_agency_id { 'GUIPS' }
    end
  end
end
