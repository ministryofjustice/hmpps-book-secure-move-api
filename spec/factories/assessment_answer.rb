# frozen_string_literal: true

FactoryBot.define do
  factory :assessment_answer do
    title { 'Needs to wear spectacles to read a book' }
    association(:profile)
    association(:assessment_answer_type)
  end
end
