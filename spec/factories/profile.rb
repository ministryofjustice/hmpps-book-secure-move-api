# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    first_names { 'Bob' }
    last_name { 'Roberts' }
    date_of_birth { Date.new(1980, 10, 20) }
  end
end
