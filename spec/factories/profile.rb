# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    forenames { 'Bob' }
    surname { 'Roberts' }
    date_of_birth { Date.new(1980, 10, 20) }
  end
end
