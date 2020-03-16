# frozen_string_literal: true

FactoryBot.define do
  factory :prison_transfer_reason do
    sequence(:key) { |n| "key#{n}" }
    title { Faker::Alphanumeric.alpha }
  end
end
