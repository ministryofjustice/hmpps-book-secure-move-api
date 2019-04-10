# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    label { 'Pentonville' }
    location_type { 'prison' }

    trait :court do
      label { 'Guildford Crown Court' }
      location_type { 'court' }
    end
  end
end
