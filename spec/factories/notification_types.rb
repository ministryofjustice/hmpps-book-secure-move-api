FactoryBot.define do
  factory :notification_type do
    trait :webhook do
      id { NotificationType::WEBHOOK }
      title { "Webhook" }
    end
    trait :email do
      id { NotificationType::EMAIL }
      title { "Email" }
    end
  end
end
