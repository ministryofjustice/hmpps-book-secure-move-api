# frozen_string_literal: true

FactoryBot.define do
  factory :move do
    association(:profile)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    sequence(:date) { |n| Date.today + n.days }
    time_due { Time.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    move_type { 'court_appearance' }
    sequence(:created_at) { |n| Time.now - n.minutes }
    sequence(:date_from) { |n| Date.today - n.days }

    trait :cancelled do
      status { 'cancelled' }
      cancellation_reason { 'other' }
      cancellation_reason_comment { 'some other reason' }
    end

    trait :prison_recall do
      move_type { 'prison_recall' }
      to_location { nil }
    end

    trait :requested do
      move_type { 'requested' }
      to_location { nil }
    end

    trait :proposed do
      status { 'proposed' }
    end

    trait :with_transfer_reason do
      association :prison_transfer_reason
    end

    trait :with_allocation do
      after(:create) do |move|
        create(
          :allocation,
          from_location: move.from_location,
          to_location: move.to_location,
          date: move.date,
          moves: [move],
        )
      end
    end
  end

  factory :from_court_to_prison, class: Move do
    association(:profile)
    association(:from_location, :court, factory: :location)
    association(:to_location, factory: :location)
    date { Date.today }
    time_due { Time.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    move_type { 'court_appearance' }
  end
end
