# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    key { 'hmp_pentonville' }
    description { 'HMP Pentonville' }
    location_type { 'prison' }
    location_code { 'PEI' }

    trait :court do
      key { 'guildford_crown_court' }
      description { 'Guildford Crown Court' }
      location_type { 'court' }
      location_code { 'GUICCT' }
    end
  end
end
