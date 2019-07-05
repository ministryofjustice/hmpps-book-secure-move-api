# frozen_string_literal: true

FactoryBot.define do
  factory :identifier_type do
    id { 'police_national_computer' }
    title { 'PNC ID' }

    trait :prison_number do
      id { 'prison_number' }
      title { 'Prisoner No' }
    end

    trait :criminal_records_office do
      id { 'criminal_records_office' }
      title { 'CRO No' }
    end
  end
end
