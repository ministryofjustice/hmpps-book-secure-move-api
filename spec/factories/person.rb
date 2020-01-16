# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    profiles { build_list :profile, 1 }
  end

  factory :person_without_profile, class: Person
end
