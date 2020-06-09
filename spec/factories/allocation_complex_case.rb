# frozen_string_literal: true

FactoryBot.define do
  factory :allocation_complex_case do
    key { 'mental_health_issue' }
    title { 'Mental Heath Issues' }

    trait :self_harm do
      key { 'self_harm' }
      title { 'Self harm / prisoners on ACCT' }
    end
  end
end
