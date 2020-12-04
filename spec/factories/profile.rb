# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    association(:person, factory: :person_without_profiles)
  end

  trait :with_person_escort_record do
    after(:create) do |profile|
      create(:person_escort_record, profile: profile)
    end
  end

  trait :with_documents do
    after(:create) do |profile|
      create_list(:document, 1, documentable: profile)
    end
  end

  trait :with_assessment_answers do
    assessment_answers do
      assessment_question = create(:assessment_question)
      [
        Profile::AssessmentAnswer.new(
          assessment_question_id: assessment_question.id,
          key: 'hold_separately',
          imported_from_nomis: false,
          category: 'risk',
        ),
        Profile::AssessmentAnswer.new(
          assessment_question_id: assessment_question.id,
          key: 'ABC',
          nomis_alert_type: 'A',
          nomis_alert_code: 'ABC',
          category: 'risk',
        ),
        Profile::AssessmentAnswer.new(
          assessment_question_id: assessment_question.id,
          key: 'XYZ',
          nomis_alert_type: 'X',
          nomis_alert_code: 'XYZ',
          category: 'health',
        ),
        Profile::AssessmentAnswer.new(
          assessment_question_id: assessment_question.id,
          key: 'not_for_release',
          imported_from_nomis: false,
          category: 'health',
        ),
      ]
    end
  end

  trait :category_supported do
    association(:category)
  end

  trait :category_not_supported do
    association(:category, :not_supported)
  end
end
