FactoryBot.define do
  factory :subscription do
    association :supplier
    secret { 'Secret' }
  end

  trait :callback_url do
    callback_url { 'http://foo.bar/?bla=bla' }
  end

  trait :email_addresses do
    email_addresses { 'user1@example.com, user2@example.com' }
  end
end
