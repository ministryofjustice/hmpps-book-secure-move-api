# frozen_string_literal: true

FactoryBot.define do
  factory :supplier do
    sequence(:name) { |n| "Test Supplier #{n}" }
  end
end
