FactoryBot.define do
  factory :journey do
    association(:move)
    association(:supplier)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    client_timestamp { Time.zone.now.utc + rand(-60..60).seconds } # NB: the client_timestamp will never be perfectly in sync with system clock
    vehicle { { id: '12345678ABC', registration: 'AB12 CDE' } }

    # NB we need to initialize_state because FactoryBot fires the after_initialize callback before the attributes are initialised!
    after(:build, &:initialize_state)

    # Journey statuses
    trait :proposed do
      state { 'proposed' }
    end

    trait :rejected do
      state { 'rejected' }
    end

    trait :in_progress do
      state { 'in_progress' }
    end

    trait :completed do
      state { 'completed' }
    end

    trait :cancelled do
      state { 'cancelled' }
    end
  end
end
