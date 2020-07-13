# frozen_string_literal: true

FactoryBot.define do
  factory :ethnicity do
    key { 'w1' }
    nomis_code { 'W1' }
    title { 'White British' }
    description { 'W1 - White British' }

    trait :asian do
      key { 'a1' }
      nomis_code { 'A1' }
      title { 'Asian or Asian British (Indian)' }
      description { 'A1 - Asian or Asian British (Indian)' }
    end

    trait :b2 do
      key { 'b2' }
      nomis_code { 'B2' }
      title { 'Black/Black British: African' }
      description { 'B2 - Black/Black British: African' }
    end
  end
end
