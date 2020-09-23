# frozen_string_literal: true

FactoryBot.define do
  factory :framework_nomis_code do
    sequence(:code) { 'XAB' }
    sequence(:code_type) { 'alert' }
  end
end
