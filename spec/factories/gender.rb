# frozen_string_literal: true

FactoryBot.define do
  factory :gender do
    title { 'Female' }

    trait :male do
      title { 'Male' }
    end
  end
end
