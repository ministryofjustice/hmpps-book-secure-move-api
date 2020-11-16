# frozen_string_literal: true

FactoryBot.define do
  factory :person_escort_record do
    association(:framework)
    association(:profile)

    after(:build, &:initialize_state)

    trait :with_responses do
      association(:framework, :with_questions)
      after(:create) do |person_escort_record|
        person_escort_record.framework_questions.each do |question|
          create(
            :string_response,
            framework_question: question,
            assessmentable: person_escort_record,
          )
        end
      end
    end

    trait :in_progress do
      status { PersonEscortRecord::PERSON_ESCORT_RECORD_IN_PROGRESS }
    end

    trait :completed do
      status { PersonEscortRecord::PERSON_ESCORT_RECORD_COMPLETED }
      completed_at { Time.zone.now }
    end

    trait :confirmed do
      status { PersonEscortRecord::PERSON_ESCORT_RECORD_CONFIRMED }
      confirmed_at { Time.zone.now }
    end

    trait :prefilled do
      association(:prefill_source, factory: :person_escort_record)
    end
  end
end
