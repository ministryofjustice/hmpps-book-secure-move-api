FactoryBot.define do
  factory :notification do
    association :subscription
    time_stamp { "2020-01-22 09:07:58" }
    event_type { "MyString" }
    object_id { "" }
    object_type { "Move" }
    delivery_attempts { 1 }
    delivery_attempted_at { "2020-01-22 09:07:58" }
    delivered_at { "2020-01-22 09:07:58" }
    data { '{ "foo": "bar" }' }
  end
end
