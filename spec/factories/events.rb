FactoryBot.define do
  factory :event do
    eventable { association(:move) }
    event_name { 'create' }
    client_timestamp { Time.now.utc + rand(-60..60).seconds } # NB: the client_timestamp will never be perfectly in sync with system clock
    details do
      { supplier_id: '1234',
        event_params: {
          attributes: { notes: 'foo' },
        },
        data_params: {
          attributes: { notes: 'bar' },
        } }
    end

    trait :create do
      event_name { 'create' }
    end

    trait :update do
      event_name { 'update' }
    end

    trait :cancel do
      event_name { 'cancel' }
    end

    trait :uncancel do
      event_name { 'uncancel' }
    end

    trait :complete do
      event_name { 'complete' }
    end

    trait :uncomplete do
      event_name { 'uncomplete' }
    end

    trait :redirect do
      event_name { 'redirect' }
    end

    trait :lockout do
      event_name { 'lockout' }
    end

    # NB: move_event factory inherits from the event factory
    factory :move_event, class: 'MoveEvent' do
      event_name { 'cancel' }
      details do
        { event_params: {
          relationships: {
            from_location: { data: { id: create(:location).id } },
            to_location: { data: { id: create(:location).id } },
          },
        } }
      end

      trait :cancel do
        details do
          { event_params: {
            attributes: {
              cancellation_reason: 'supplier_declined_to_move',
              cancellation_reason_comment: 'computer says no',
            },
          } }
        end
      end
    end
  end
end
