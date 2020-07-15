# frozen_string_literal: true

FactoryBot.define do
  factory :framework do
    sequence(:name) { |x| "person-escort-record-#{x}" }
    version { '0.1' }

    trait :with_questions do
      after(:create) do |framework|
        create_list(:framework_question, 2, framework: framework)
      end
    end
  end
end
