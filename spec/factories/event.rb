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

    trait :lodging do
      event_name { 'lodging' }
    end

    trait :approve do
      event_name { 'approve' }
    end

    trait :reject do
      event_name { 'reject' }
    end

    trait :accept do
      event_name { 'accept' }
    end

    trait :start do
      event_name { 'start' }
    end

    trait :locations do
      details do
        { supplier_id: '1234',
          event_params: {
            attributes: { notes: 'foo' },
            relationships: {
              from_location: { data: { id: create(:location).id } },
              to_location: { data: { id: create(:location).id } },
            },
          },
          data_params: {
            attributes: { notes: 'bar' },
          } }
      end
    end

    # NB: move_event factory inherits from the event factory
    factory :move_event, class: 'MoveEvent' do
      details do
        { event_params: {
          relationships: {
            from_location: { data: { id: create(:location).id } },
            to_location: { data: { id: create(:location).id } },
          },
        } }
      end

      trait :cancel do
        event_name { 'cancel' }
        details do
          { event_params: {
            attributes: {
              cancellation_reason: 'supplier_declined_to_move',
              cancellation_reason_comment: 'computer says no',
            },
          } }
        end
      end

      trait :broken_cancel do
        event_name { 'cancel' }
        details do
          { event_params: {
            attributes: {
              cancellation_reason: nil,
              cancellation_reason_comment: 'this is a broken event',
            },
          } }
        end
      end

      trait :approve do
        event_name { 'approve' }
        details do
          { event_params: {
            attributes: {
              date: Date.tomorrow,
            },
          } }
        end
      end

      trait :approve_with_nomis do
        event_name { 'approve' }
        details do
          { event_params: {
            attributes: {
              date: Date.tomorrow,
              create_in_nomis: true,
            },
          } }
        end
      end

      trait :reject do
        event_name { 'reject' }
        details do
          { event_params: {
            attributes: {
              rejection_reason: 'no_transport_available',
              cancellation_reason_comment: 'computer says no',
            },
          } }
        end
      end

      trait :reject_with_rebook do
        event_name { 'reject' }
        details do
          { event_params: {
            attributes: {
              rejection_reason: 'no_transport_available',
              cancellation_reason_comment: 'computer says no',
              rebook: true,
            },
          } }
        end
      end
    end
  end
end
