FactoryBot.define do
  factory :notification do
    association :subscription

    notification_type do
      NotificationType.find_or_create_by(id: 'webhook', title: 'Webhook')
    end

    event_type { 'move_created' }
    association :topic, factory: :move
    delivery_attempts { 0 }
    delivery_attempted_at { '2020-01-22 09:07:58' }
    delivered_at { '2020-01-22 09:07:58' }
  end

  trait(:email) do
    notification_type do
      NotificationType.find_or_create_by(id: 'email', title: 'Email')
    end
  end

  trait(:webhook) do
    notification_type do
      NotificationType.find_or_create_by(id: 'webhook', title: 'Webhook')
    end
  end
end
