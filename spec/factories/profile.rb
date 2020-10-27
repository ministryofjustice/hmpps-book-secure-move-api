# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    association(:person, factory: :person_without_profiles)
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

  trait :category_a do
    category { 'Cat A' }
    category_code { 'A' }
  end

  trait :category_h do
    category { 'Cat A-Hi' }
    category_code { 'H' }
  end

  trait :category_e do
    category { 'Cat A-Ex' }
    category_code { 'E' }
  end

  trait :category_b do
    category { 'Cat B' }
    category_code { 'B' }
  end

  trait :category_c do
    category { 'Cat C' }
    category_code { 'C' }
  end

  trait :category_d do
    category { 'Cat D' }
    category_code { 'D' }
  end

  trait :category_u do
    category { 'Unsentenced' }
    category_code { 'U' }
  end

  trait :category_unknown do
    category { nil }
    category_code { nil }
  end
end
