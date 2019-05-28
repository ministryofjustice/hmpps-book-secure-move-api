# frozen_string_literal: true

FactoryBot.define do
  factory :profile_attribute_type do
    category { 'health' }
    user_type { 'prison' }
    alert_type { 'M' }
    alert_code { 'MSI' }
    description { 'Sight Impaired' }

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
