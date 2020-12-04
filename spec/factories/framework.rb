# frozen_string_literal: true

FactoryBot.define do
  factory :framework do
    name { 'person-escort-record' }
    version { '0.1' }

    initialize_with { Framework.find_or_create_by(name: name, version: version) }

    trait :youth_risk_assessment do
      name { 'youth-risk-assessment' }
    end

    trait :with_questions do
      after(:create) do |framework|
        create_list(:framework_question, 2, framework: framework)
      end
    end
  end
end
