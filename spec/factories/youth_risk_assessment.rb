# frozen_string_literal: true

FactoryBot.define do
  factory :youth_risk_assessment do
    association(:framework)
    association(:profile)
    association(:move)

    after(:build, &:initialize_state)

    trait :with_responses do
      association(:framework, :with_questions)
      after(:create) do |youth_risk_assessment|
        youth_risk_assessment.framework_questions.each do |question|
          create(
            :string_response,
            framework_question: question,
            assessmentable: youth_risk_assessment,
          )
        end
      end
    end

    trait :in_progress do
      status { YouthRiskAssessment::YOUTH_ASSESSMENT_IN_PROGRESS }
    end

    trait :completed do
      status { YouthRiskAssessment::YOUTH_ASSESSMENT_COMPLETED }
    end

    trait :confirmed do
      status { YouthRiskAssessment::YOUTH_ASSESSMENT_CONFIRMED }
      confirmed_at { Time.zone.now }
    end

    trait :prefilled do
      association(:prefill_source, factory: :youth_risk_assessment)
    end
  end
end
