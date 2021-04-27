# frozen_string_literal: true

FactoryBot.define do
  factory :move do
    association(:profile)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    sequence(:date) { |n| Date.today + n.days }
    time_due { Time.zone.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    sequence(:created_at) { |n| Time.zone.now - n.minutes }
    sequence(:date_from) { |n| Date.today - n.days }

    association(:supplier)

    # NB we need to initialize_state because FactoryBot fires the after_initialize callback before the attributes are initialised!
    after(:build, &:initialize_state)

    # Move types
    trait :court_appearance do
      # NB: Police / Prison / STC / SCH --> Court
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

    trait :police_transfer do
      move_type { 'police_transfer' }
      association(:from_location, :police, factory: :location)
      association(:to_location, :police, factory: :location)
    end

    trait :video_remand do
      move_type { 'video_remand' }
      association(:from_location, :police, factory: :location)
      to_location { nil } # NB: to_location is always nil for a video_remand
    end

    trait :hospital do
      move_type { 'hospital' }
      association(:from_location, :police, factory: :location)
      association(:to_location, :high_security_hospital, factory: :location)
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

    trait :rejected_no_space do
      status { 'cancelled' }
      cancellation_reason { 'rejected' }
      cancellation_reason_comment { 'no space available at the receiving prison' }
      rejection_reason { 'no_space_at_receiving_prison' }
    end

    trait :rejected_no_transport do
      status { 'cancelled' }
      cancellation_reason { 'rejected' }
      cancellation_reason_comment { 'no transportation available to move prisoner' }
      rejection_reason { 'no_transport_available' }
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

    trait :with_journey do
      after(:create) do |move|
        create(:journey, from_location: move.from_location, to_location: move.to_location, move: move)
      end
    end

    trait :with_person_escort_record do
      transient do
        person_escort_record_status { 'unstarted' }
      end

      after(:create) do |move, evaluator|
        create(
          :person_escort_record,
          move: move,
          status: evaluator.person_escort_record_status,
          confirmed_at: evaluator.person_escort_record_status == 'confirmed' ? Time.zone.now : nil,
          completed_at: evaluator.person_escort_record_status == 'completed' ? Time.zone.now : nil,
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

    trait :from_stc_to_court do
      association(:from_location, :stc, factory: :location)
      association(:to_location, :court, factory: :location)

      move_type { 'court_appearance' }
    end
  end

  factory :from_prison_to_court, class: 'Move' do
    association(:profile)
    association(:from_location, :prison, factory: :location)
    association(:to_location, :court, factory: :location)
    association(:supplier)

    date { Date.today }
    time_due { Time.zone.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    move_type { 'court_appearance' }

    # NB we need to initialize_state because FactoryBot fires the after_initialize callback before the attributes are initialised!
    after(:build, &:initialize_state)
  end
end
