FactoryBot.define do
  factory :notification do
    association :subscription
    event_type { 'move_created' }
    association :topic, factory: :move
    delivery_attempts { 0 }
    delivery_attempted_at { '2020-01-22 09:07:58' }
    delivered_at { '2020-01-22 09:07:58' }
  end
end
