# frozen_string_literal: true

FactoryBot.define do
  factory :framework do
    sequence(:name) { |x| "person-escort-record-#{x}" }
    version { '0.1' }
  end
end
