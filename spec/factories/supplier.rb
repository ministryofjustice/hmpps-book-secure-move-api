# frozen_string_literal: true

FactoryBot.define do
  factory :supplier do
    sequence(:name) { |n| "Test Supplier #{n}" }

    trait :geoamey do
      name { 'Geoamey' }
      key { 'geoamey' }
    end

    trait :serco do
      name { 'Serco' }
      key { 'serco' }
    end
  end
end
