# frozen_string_literal: true

FactoryBot.define do
  factory :person_escort_record do
    association(:framework)
    association(:profile)
    state { 'not_started' }
  end
end
