# frozen_string_literal: true

FactoryBot.define do
  factory :assessment_question do
    category { 'health' }
    key { 'sight_impaired' }
    title { 'Sight Impaired' }

    trait :care_needs_fallback do
      category { 'health' }
      key { PersonalCareNeeds::Importer::QUESTION_KEY_FALLBACK  }
      title { 'Pregnancy' }
    end

    trait :alerts_fallback do
      key { Alerts::Importer::FALLBACK_QUESTION_KEY }
      category { 'risk' }
      title { 'Other Risks' }
    end

    trait :risk do
      category { 'risk' }
    end

    trait :health do
      category { 'health' }
    end

    trait :court do
      category { 'court' }
    end
  end
end
