# frozen_string_literal: true

FactoryBot.define do
  factory :gender do
    key { 'female' }
    nomis_code { 'F' }
    title { 'Female' }

    trait :male do
      key { 'male' }
      title { 'Male' }
      nomis_code { 'M' }
    end
  end
end
