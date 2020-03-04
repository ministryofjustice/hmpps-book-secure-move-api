FactoryBot.define do
  factory :notification do
    association :subscription
    association :notification_type, :webhook # defaults to webhook
    event_type { 'move_created' }
    association :topic, factory: :move
    delivery_attempts { 0 }
    delivery_attempted_at { '2020-01-22 09:07:58' }
    delivered_at { '2020-01-22 09:07:58' }
  end

  trait(:email) do
    association :notification_type, :email
  end

  trait(:webhook) do
    association :notification_type, :webhook
  end
end
