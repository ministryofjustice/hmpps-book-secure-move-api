# frozen_string_literal: true

FactoryBot.define do
  factory :person_escort_record do
    association(:framework)
    association(:profile)
    state { 'in_progress' }

    trait :with_responses do
      association(:framework, :with_questions)
      after(:create) do |person_escort_record|
        person_escort_record.framework_questions.each do |question|
          create(
            :string_response,
            framework_question: question,
            person_escort_record: person_escort_record,
          )
        end
      end
    end
  end
end
