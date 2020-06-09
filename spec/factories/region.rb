# frozen_string_literal: true

FactoryBot.define do
  factory :region do
    sequence(:key) { |x| "key_#{x}" }
    sequence(:name) { |x| "#{Faker::Address.state}_#{x}" }
  end
end
