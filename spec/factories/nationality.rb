# frozen_string_literal: true

FactoryBot.define do
  factory :nationality do
    key { 'british' }
    title { 'British' }

    trait :french do
      key { 'french' }
      title { 'French' }
    end
  end
end
