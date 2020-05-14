# frozen_string_literal: true

FactoryBot.define do
  factory :allocation do
    association(:from_location, factory: :location)
    association(:to_location, factory: :location)
    sequence(:date) { |n| Date.today + n.days }

    prisoner_category { Allocation.prisoner_categories.values.sample }
    sentence_length { Allocation.sentence_lengths.values.sample }
    moves_count { Faker::Number.non_zero_digit }
    complete_in_full { false }

    trait :with_moves do
      moves_count { 1 }
      after(:create) do |allocation|
        create_list(
          :move,
          allocation.moves_count,
          from_location: allocation.from_location,
          to_location: allocation.to_location,
          date: allocation.date,
          status: 'requested',
          allocation: allocation,
        )
      end
    end
  end
end
