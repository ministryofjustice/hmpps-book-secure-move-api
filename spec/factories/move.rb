# frozen_string_literal: true

FactoryBot.define do
  factory :move do
    association(:person)
    association(:from_location, factory: :location)
    association(:to_location, :court, factory: :location)
    date { Date.today }
    time_due { Time.now }
    status { 'requested' }
    additional_information { 'some more info about the move that the supplier might need to know' }
    move_type { 'court_appearance' }
  end
end
