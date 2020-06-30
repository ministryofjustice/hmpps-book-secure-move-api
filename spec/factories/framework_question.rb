# frozen_string_literal: true

FactoryBot.define do
  factory :framework_question do
    association(:framework)
    sequence(:key) { |x| "key-#{x}" }
    section { 'risk' }
    question_type { 'radio' }
    options { %w[Yes No] }
  end
end
