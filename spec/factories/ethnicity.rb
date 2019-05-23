# frozen_string_literal: true

FactoryBot.define do
  factory :ethnicity do
    code { 'W1' }
    title { 'White British' }
    description { 'W1 - White British' }

    trait :asian do
      code { 'A1' }
      title { 'Asian or Asian British (Indian)' }
      description { 'A1 - Asian or Asian British (Indian)' }
    end
  end
end
