# frozen_string_literal: true

FactoryBot.define do
  factory :move do
    association(:person)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    date { Date.today }
    time_due { Time.now }
    status { 'requested' }
  end
end
