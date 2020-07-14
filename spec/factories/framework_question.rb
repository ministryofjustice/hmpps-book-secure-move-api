# frozen_string_literal: true

FactoryBot.define do
  factory :framework_question do
    association(:framework)
    sequence(:key) { |x| "key-#{x}" }
    section { 'risk' }
    question_type { 'radio' }
    options { %w[Yes No] }

    trait :text do
      question_type { 'text' }
      options { [] }
    end

    trait :textarea do
      question_type { 'textarea' }
      options { [] }
    end

    trait :checkbox do
      question_type { 'checkbox' }
      options { ['Level 1', 'Level 2'] }
    end
  end
end
