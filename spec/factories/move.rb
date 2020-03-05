# frozen_string_literal: true

FactoryBot.define do
  factory :move do
    association(:person)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    sequence(:date) { |n| Date.today + n.days }
    time_due { Time.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    move_type { 'court_appearance' }

    trait :cancelled do
      status { 'cancelled' }
      cancellation_reason { 'other' }
      cancellation_reason_comment { 'some other reason' }
    end

    trait :proposed do
      status { 'proposed' }
    end
  end

  factory :from_court_to_prison, class: Move do
    association(:person)
    association(:from_location, :court, factory: :location)
    association(:to_location, factory: :location)
    date { Date.today }
    time_due { Time.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    move_type { 'court_appearance' }
  end
end
