FactoryBot.define do
  factory :event do
    association(:eventable)
    event_name { 'create' }
    client_timestamp { Time.now.utc + rand(-60..60).seconds } # NB: the client_timestamp will never be perfectly in sync with system clock

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
  end
end
