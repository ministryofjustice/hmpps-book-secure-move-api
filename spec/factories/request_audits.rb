FactoryBot.define do
  factory :request_audit do
    request { 'url_with_parameters' }

    association :application
  end
end
