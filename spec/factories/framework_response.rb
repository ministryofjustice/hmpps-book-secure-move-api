# frozen_string_literal: true

FactoryBot.define do
  factory :framework_response do
    association(:framework_question)
    association(:person_escort_record)
    value_type { 'string' }
  end
end
