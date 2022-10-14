# frozen_string_literal: true

FactoryBot.define do
  factory :allocation do
    association(:from_location, factory: :location)
    association(:to_location, factory: :location)
    sequence(:date) { |n| Time.zone.today + n.days }

    prisoner_category { Allocation.prisoner_categories.values.sample }
    sentence_length { Allocation.sentence_lengths.values.sample }
    estate { Allocation.estates.values.sample }
    requested_by { Faker::Name.name }
    moves_count { Faker::Number.non_zero_digit }
    complete_in_full { false }

    # NB we need to initialize_state because FactoryBot fires the after_initialize callback before the attributes are initialised!
    after(:build, &:initialize_state)

    trait :unfilled do
      status { 'unfilled' }
    end
    trait :filled do
      status { 'filled' }
    end
    trait :cancelled do
      status { 'cancelled' }
      cancellation_reason { 'other' }
    end

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

    trait :with_5_moves do
      moves_count { 5 }
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
