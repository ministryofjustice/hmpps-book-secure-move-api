# frozen_string_literal: true

FactoryBot.define do
  factory :profile_attribute_type do
    category { 'health' }
    user_type { 'prison' }
  end
end
