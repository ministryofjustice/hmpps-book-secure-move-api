# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    description { 'HMP Pentonville' }
    location_type { 'prison' }
    location_code { 'PEI' }

    trait :court do
      description { 'Guildford Crown Court' }
      location_type { 'court' }
      location_code { 'GUICCT' }
    end
  end
end
