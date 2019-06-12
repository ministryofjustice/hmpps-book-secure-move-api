# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    first_names { 'Tom' }
    last_name { 'Thompson' }
    date_of_birth { Date.new(1980, 10, 20) }
    association(:ethnicity)
    association(:gender)
  end
end
