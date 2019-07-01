# frozen_string_literal: true

FactoryBot.define do
  factory :identifier_type do
    id { 'pnc_number' }
    title { 'PNC ID' }

    trait :prison_number do
      key { 'prison_number' }
      title { 'Prisoner No' }
    end

    trait :cro_number do
      key { 'cro_number' }
      title { 'CRO No' }
    end
  end
end

