FactoryBot.define do
  factory :generic_event do
    eventable { association(:move) }
    occurred_at { Time.zone.now }
    recorded_at { Time.zone.now }
    notes { 'Flibble' }
    created_by { GenericEvent::CREATED_BY_OPTIONS.sample }
  end

  factory :event_move_accept, parent: :generic_event, class: 'GenericEvent::MoveAccept' do
    eventable { association(:move) }
  end

  factory :event_move_approve, parent: :generic_event, class: 'GenericEvent::MoveApprove' do
    eventable { association(:move) }
    details do
      {
        date: '2020-06-16',
        create_in_nomis: true,
      }
    end
  end

  factory :event_move_cancel, parent: :generic_event, class: 'GenericEvent::MoveCancel' do
    details do
      {
        cancellation_reason: 'made_in_error',
        cancellation_reason_comment: 'It was a mistake',
      }
    end
  end

  factory :event_move_complete, parent: :generic_event, class: 'GenericEvent::MoveComplete' do
    eventable { association(:move) }
  end

  factory :event_move_lockout, parent: :generic_event, class: 'GenericEvent::MoveLockout' do
    eventable { association(:move) }
    details do
      {
        from_location_id: create(:location).id,
      }
    end
  end

  factory :event_move_redirect, parent: :generic_event, class: 'GenericEvent::MoveRedirect' do
    eventable { association(:move) }
    details do
      {
        move_type: 'court_appearance',
        to_location_id: create(:location).id,
      }
    end
  end

  factory :event_move_reject, parent: :generic_event, class: 'GenericEvent::MoveReject' do
    eventable { association(:move) }
    details do
      {
        rejection_reason: 'no_space_at_receiving_prison',
        cancellation_reason_comment: 'It was a mistake',
        rebook: false,
      }
    end
  end

  factory :event_move_start, parent: :generic_event, class: 'GenericEvent::MoveStart' do
    eventable { association(:move) }
  end

  factory :event_journey_cancel, parent: :generic_event, class: 'GenericEvent::JourneyCancel' do
    eventable { association(:journey) }
  end

  factory :event_journey_complete, parent: :generic_event, class: 'GenericEvent::JourneyComplete' do
    eventable { association(:journey) }
  end

  factory :event_journey_lockout, parent: :generic_event, class: 'GenericEvent::JourneyLockout' do
    eventable { association(:journey) }
    details do
      {
        from_location_id: create(:location).id,
      }
    end
  end

  factory :event_journey_lodging, parent: :generic_event, class: 'GenericEvent::JourneyLodging' do
    eventable { association(:journey) }
    details do
      {
        to_location_id: create(:location).id,
      }
    end
  end

  factory :event_journey_reject, parent: :generic_event, class: 'GenericEvent::JourneyReject' do
    eventable { association(:journey) }
  end

  factory :event_journey_start, parent: :generic_event, class: 'GenericEvent::JourneyStart' do
    eventable { association(:journey) }
  end

  factory :event_journey_uncancel, parent: :generic_event, class: 'GenericEvent::JourneyUncancel' do
    eventable { association(:journey) }
  end

  factory :event_journey_uncomplete, parent: :generic_event, class: 'GenericEvent::JourneyUncomplete' do
    eventable { association(:journey) }
  end
end
