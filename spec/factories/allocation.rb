# frozen_string_literal: true

FactoryBot.define do
  factory :allocation do
    association(:from_location, factory: :location)
    association(:to_location, factory: :location)
    sequence(:date) { |n| Date.today + n.days }

    prisoner_category { Allocation.prisoner_categories.values.sample }
    sentence_length { Allocation.sentence_lengths.values.sample }
    moves_count { Faker::Number.digit }
    complete_in_full { false }
  end
end
