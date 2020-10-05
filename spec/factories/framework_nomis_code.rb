# frozen_string_literal: true

FactoryBot.define do
  factory :framework_nomis_code do
    code { 'XAB' }
    code_type { 'alert' }
  end
end
