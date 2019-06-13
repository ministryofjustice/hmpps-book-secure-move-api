# frozen_string_literal: true

FactoryBot.define do
  factory :assessment_answer_type do
    category { 'health' }
    nomis_alert_type { 'M' }
    nomis_alert_code { 'MSI' }
    title { 'Sight Impaired' }

    trait :risk do
      category { 'risk' }
    end

    trait :health do
      category { 'health' }
    end

    trait :court_information do
      category { 'court_information' }
    end
  end
end
