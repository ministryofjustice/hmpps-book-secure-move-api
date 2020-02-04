FactoryBot.define do
  factory :subscription do
    association :supplier
    webhook_url { "http://foo.bar/" }
    username { "Username" }
    password { "Password" }
    secret { "Secret" }
  end
end
