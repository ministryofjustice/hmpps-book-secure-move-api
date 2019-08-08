# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    key { 'hmp_pentonville' }
    title { 'HMP Pentonville' }
    location_type { 'prison' }
    nomis_agency_id { 'PEI' }

    trait :court do
      key { 'guildford_crown_court' }
      title { 'Guildford Crown Court' }
      location_type { 'court' }
      nomis_agency_id { 'GUICCT' }
    end

    trait :police do
      key { 'guildford_police_station' }
      title { 'Guildford Police Station' }
      location_type { 'police' }
      nomis_agency_id { 'GUIPS' }
    end
  end
end
