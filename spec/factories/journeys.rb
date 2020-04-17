FactoryBot.define do
  factory :journey do
    association(:move)
    association(:supplier)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    client_timestamp { Time.now.utc + rand(-60..60).seconds } # NB: the client_timestamp will never be perfectly in sync with system clock

    # NB we need to initialize_state because FactoryBot fires the after_initialize callback before the attributes are initialised!
    after(:build) { |object| object.send(:initialize_state) }
  end
end
