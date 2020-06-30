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

    # Move types
    trait :court_appearance do
      # NB: Police / Prison / STC / SCH, YOI --> Court
      move_type { 'court_appearance' }
      association(:from_location, :police, factory: :location)
      association(:to_location, :court, factory: :location)
    end
    trait :prison_recall do
      # NB: Police --> Prison
      move_type { 'prison_recall' }
      association(:from_location, :police, factory: :location)
      to_location { nil } # NB: to_location is always nil for a prison_recall
    end
    trait :prison_transfer do
      # NB: believed to be Prison 1 --> Prison 2
      move_type { 'prison_transfer' }
      association(:from_location, :prison, factory: :location)
      association(:to_location, :prison, factory: :location)
      association(:prison_transfer_reason)
    end

    # Move statuses
    trait :proposed do
      status { 'proposed' }
    end
    trait :requested do
      status { 'requested' }
    end
    trait :booked do
      status { 'booked' }
    end
    trait :in_transit do
      status { 'in_transit' }
    end
    trait :cancelled do
      status { 'cancelled' }
      cancellation_reason { 'other' }
      cancellation_reason_comment { 'some other reason' }
    end
    trait :completed do
      status { 'completed' }
    end

    # cancellation_reasons
    trait :cancelled_made_in_error do
      status { 'cancelled' }
      cancellation_reason { 'made_in_error' }
      cancellation_reason_comment { 'the move was made in error' }
    end
    trait :cancelled_supplier_declined_to_move do
      status { 'cancelled' }
      cancellation_reason { 'supplier_declined_to_move' }
      cancellation_reason_comment { 'the supplier declined to move' }
    end
    trait :cancelled_rejected do
      status { 'cancelled' }
      cancellation_reason { 'rejected' }
      cancellation_reason_comment { 'the proposed move was rejected' }
    end
    trait :cancelled_other do
      status { 'cancelled' }
      cancellation_reason { 'other' }
      cancellation_reason_comment { 'the move was cancelled because of some other reason' }
    end

    # Other traits
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

    trait :with_date_to do
      date_to { date + 3.days }
    end

    trait :with_original_move do
      association(:original_move, factory: :move)
    end

    trait :with_court_hearings do
      after(:create) do |move|
        create_list(:court_hearing, 1, move: move)
      end
    end
  end

  factory :from_court_to_prison, class: 'Move' do
    association(:profile)
    association(:from_location, :court, factory: :location)
    association(:to_location, :prison, factory: :location)
    date { Date.today }
    time_due { Time.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    move_type { 'court_appearance' }
  end
end
