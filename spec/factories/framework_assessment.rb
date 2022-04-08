# frozen_string_literal: true

FactoryBot.define do
  factory :framework_assessmentable do
    after(:build, &:initialize_state)

    trait :with_responses do
      after(:create) do |assessment|
        create_list(:framework_question, 2, framework: assessment.framework, required: true)
        assessment.framework_questions.each do |question|
          create(
            :string_response,
            framework_question: question,
            assessmentable: assessment,
          )
        end
      end
    end

    trait :unstarted do
      status { 'unstarted' }
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

    trait :handover do
      status { FrameworkAssessmentable::ASSESSMENT_CONFIRMED }
      confirmed_at { Time.zone.now }
      handover_occurred_at { Time.zone.now }
      handover_details do
        {
          'dispatching_officer' => 'Derek Dispatcher',
          'dispatching_officer_id' => 'D100',
          'dispatching_officer_contact' => '0123 456 789',
          'receiving_officer' => 'Roberta Receiver',
          'receiving_officer_id' => 'R200',
          'receiving_officer_contact' => '0987 654 321',
          'receiving_organisation' => 'Supplier Co',
        }
      end
    end
  end

  factory :person_escort_record, class: 'PersonEscortRecord', parent: :framework_assessmentable do
    association(:framework)
    move { create(:move, *move_attr) }
    profile { move.profile }

    transient do
      move_attr { nil }
    end

    trait :without_move do
      association(:profile)
      move { nil }
    end

    trait :prefilled do
      association(:prefill_source, factory: :person_escort_record)
    end

    trait :amended do
      amended_at { Time.zone.now }
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
