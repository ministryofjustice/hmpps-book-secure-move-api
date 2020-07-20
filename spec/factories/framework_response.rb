# frozen_string_literal: true

FactoryBot.define do
  factory :framework_response do
    association(:framework_question)
    association(:person_escort_record)
  end

  factory :object_response, parent: :framework_response, class: 'FrameworkResponse::Object' do
    trait :details do
      association(:framework_question, followup_comment: true)
      value { { 'option' => 'Yes', 'details' => 'some comment' } }
    end
  end

  factory :collection_response, parent: :framework_response, class: 'FrameworkResponse::Collection' do
    value { [{ 'name' => 'Foo bar' }, { 'name' => 'Bar baz' }] }
    trait :details do
      association(:framework_question, :checkbox, followup_comment: true)
      value { [{ 'option' => 'Level 1', 'details' => 'some comment' }, { 'option' => 'Level 2', 'details' => 'another comment' }] }
    end
  end

  factory :string_response, parent: :framework_response, class: 'FrameworkResponse::String' do
    value { 'Yes' }
  end

  factory :array_response, parent: :framework_response, class: 'FrameworkResponse::Array' do
    association(:framework_question, options: ['Level 1', 'Level 2'])
    value { ['Level 1'] }
  end
end
