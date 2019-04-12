# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    forenames { 'Bob' }
    surname { 'Roberts' }
  end
end
