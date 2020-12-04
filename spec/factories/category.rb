# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:key) { |x| "key_#{x}" }
    title { "Category #{Faker::Alphanumeric.alpha(number: 1)}" }
    move_supported { true }

    trait :not_supported do
      move_supported { false }
    end

    trait :cat_c do
      key { 'C' }
      title { 'Cat C' }
      move_supported { true }
    end
  end
end
