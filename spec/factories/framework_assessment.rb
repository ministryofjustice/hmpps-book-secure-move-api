# frozen_string_literal: true

FactoryBot.define do
  factory :framework_assessmentable do
    after(:build, &:initialize_state)

    trait :with_responses do
      after(:create) do |assessment|
        create_list(:framework_question, 2, framework: assessment.framework)
        assessment.framework_questions.each do |question|
          create(
            :string_response,
            framework_question: question,
            assessmentable: assessment,
          )
        end
      end
    end

    trait :in_progress do
      status { FrameworkAssessmentable::ASSESSMENT_IN_PROGRESS }
    end

    trait :completed do
      status { FrameworkAssessmentable::ASSESSMENT_COMPLETED }
      completed_at { Time.zone.now }
    end

    trait :confirmed do
      status { FrameworkAssessmentable::ASSESSMENT_CONFIRMED }
      confirmed_at { Time.zone.now }
    end
  end

  factory :person_escort_record, class: 'PersonEscortRecord', parent: :framework_assessmentable do
    association(:profile)
    association(:move)
    association(:framework)

    trait :prefilled do
      association(:prefill_source, factory: :person_escort_record)
    end
  end

  factory :youth_risk_assessment, class: 'YouthRiskAssessment', parent: :framework_assessmentable do
    association(:move, :from_stc_to_court, factory: :move)
    association(:framework, :youth_risk_assessment)

    after(:build) do |youth_risk_assessment|
      youth_risk_assessment.profile = youth_risk_assessment.move&.profile if youth_risk_assessment.profile.blank?
    end

    trait :prefilled do
      association(:prefill_source, factory: :youth_risk_assessment)
    end
  end
end
