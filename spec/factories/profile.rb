# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    association(:person, factory: :person_without_profiles)
  end

  trait :with_documents do
    after(:create) do |profile|
      create_list(:document, 1, documentable: profile)
    end
  end
end
