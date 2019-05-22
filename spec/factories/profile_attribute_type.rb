# frozen_string_literal: true

FactoryBot.define do
  factory :profile_attribute_type do
    category { 'health' }
    user_type { 'prison' }
    alert_type { 'M' }
    alert_code { 'MSI' }
    description { 'Sight Impaired' }
  end
end
