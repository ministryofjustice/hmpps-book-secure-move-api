# frozen_string_literal: true

FactoryBot.define do
  factory :prison_transfer_reason do
    key { 'reason_other' }
    title { 'Other' }
  end
end
