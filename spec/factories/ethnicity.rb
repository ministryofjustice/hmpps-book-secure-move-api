# frozen_string_literal: true

FactoryBot.define do
  factory :ethnicity do
    value { 'IC1' }
    description { 'White British' }

    trait :asian do
      value { 'IC4' }
      description { 'Asian or Asian British (Indian)' }
    end
  end
end
