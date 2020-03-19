FactoryBot.define do
  factory :subscription do
    association :supplier
    secret { 'Secret' }
    callback_url { 'http://foo.bar/?bla=bla' }
    email_address { 'user1@example.com' }
  end

  trait :no_callback_url do
    callback_url { nil }
  end

  trait :no_email_address do
    email_address { nil }
  end
end
