FactoryBot.define do
  factory :subscription do
    association :supplier
    callback_url { 'http://foo.bar/?bla=bla' }
    secret { 'Secret' }
  end
end
