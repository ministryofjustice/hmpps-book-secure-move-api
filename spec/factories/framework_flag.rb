# frozen_string_literal: true

FactoryBot.define do
  factory :framework_flag do
    sequence(:title) { |x| "High public interest #{x}" }
    sequence(:flag_type) { 'warning' }
    sequence(:question_value) { 'Yes' }

    association(:framework_question)
  end
end
