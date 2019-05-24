# frozen_string_literal: true

FactoryBot.define do
  factory :nationality do
    title { 'British' }

    trait :french do
      title { 'French' }
    end
  end
end
