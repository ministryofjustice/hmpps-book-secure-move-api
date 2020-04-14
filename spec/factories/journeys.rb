FactoryBot.define do
  factory :journey do
    association(:move)
    association(:supplier)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    client_timestamp { Time.now.utc + 2.minutes } # NB: the client_timestamp will never be perfectly in sync with system clock

    # NB we need to restore_state_machine because FactoryBot fires the after_initialize before the attributes are initialised!
    after(:build) { |object| object.send(:restore_state_machine) }
  end
end
