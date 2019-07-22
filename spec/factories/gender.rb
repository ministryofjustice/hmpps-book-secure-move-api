# frozen_string_literal: true

FactoryBot.define do
  factory :gender do
    key { 'female' }
    title { 'Female' }
    visible { true }

    trait :male do
      key { 'male' }
      title { 'Male' }
    end
  end
end
