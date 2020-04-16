FactoryBot.define do
  factory :event do
    association(:move)
    event_type { 'move_created' }
    client_timestamp { Time.now.utc + rand(-60..60).seconds } # NB: the client_timestamp will never be perfectly in sync with system clock

    trait :move_created do
      event_type { 'move_created' }
    end

    trait :move_updated do
      event_type { 'move_updated' }
    end

    trait :move_completed do
      event_type { 'move_completed' }
    end

    trait :move_cancelled do
      event_type { 'move_cancelled' }
    end

    trait :move_redirected do
      event_type { 'move_redirected' }
    end

    trait :move_lockout do
      event_type { 'move_lockout' }
    end

    trait :journey_created do
      event_type { 'journey_created' }
    end

    trait :journey_updated do
      event_type { 'journey_updated' }
    end

    trait :journey_completed do
      event_type { 'journey_completed' }
    end

    trait :journey_uncompleted do
      event_type { 'journey_uncompleted' }
    end

    trait :journey_cancelled do
      event_type { 'journey_cancelled' }
    end

    trait :journey_uncancelled do
      event_type { 'journey_uncancelled' }
    end
  end
end
