# frozen_string_literal: true

FactoryBot.define do
  factory :user_token do
    user_name { 'Bob' }
    user_id { 'BOB_GEN' }
    access_token { '123456' }
    refresh_token { '234567' }
    expires_at { 20.minutes.from_now }
  end
end
