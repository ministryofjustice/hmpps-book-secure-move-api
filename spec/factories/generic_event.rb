FactoryBot.define do
  factory :generic_event do
    eventable { association(:move) }
    occurred_at { Time.zone.now }
    notes { 'Flibble' }
    created_by { GenericEvent::CREATED_BY_OPTIONS.sample }
  end

  factory :event_move_cancel, parent: :generic_event, class: 'GenericEvent::MoveCancel' do
    details do
      {
        cancellation_reason: 'made_in_error',
        cancellation_reason_comment: 'It was a mistake',
      }
    end
  end
end
