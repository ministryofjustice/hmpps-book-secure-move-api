# frozen_string_literal: true

FactoryBot.define do
  factory :nomis_alert do
    description { 'Risk to people' }
    type_description { 'Risk' }
    code { 'RTP' }
    type_code { 'R' }
  end
end
