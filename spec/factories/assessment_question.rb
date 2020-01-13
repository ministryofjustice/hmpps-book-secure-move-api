# frozen_string_literal: true

FactoryBot.define do
  factory :assessment_question do
    category { 'health' }
    key { 'sight_impaired' }
    title { 'Sight Impaired' }

    trait :fallback do
      category { 'health' }
      key { PersonalCareNeeds::Importer::FALLBACK_QUESTION_KEY }
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
