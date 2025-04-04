FactoryBot.define do
  factory :user_audit_log do
    sequence(:name) { |n| "Test User #{n}" }
    sequence(:ip_address) { |n| "192.168.1.#{n}" }
  end
end
