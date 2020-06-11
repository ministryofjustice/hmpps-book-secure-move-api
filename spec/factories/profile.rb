# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    association(:person, factory: :person_without_profiles)
  end
end
