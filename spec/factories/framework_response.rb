# frozen_string_literal: true

FactoryBot.define do
  factory :framework_response do
    association(:framework_question)
    association(:assessmentable, factory: :person_escort_record)
    value_type { framework_question.response_type }
    section { framework_question.section }
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

    trait :multiple_items do
      association(:framework_question, :add_multiple_items)
      value do
        [
          { 'item' => 1, 'responses' => [{ 'value' => ['Level 1'], 'framework_question_id' => framework_question.dependents.first.id }] },
          { 'item' => 2, 'responses' => [{ 'value' => ['Level 2'], 'framework_question_id' => framework_question.dependents.first.id }] },
        ]
      end
    end
  end

  factory :string_response, parent: :framework_response, class: 'FrameworkResponse::String' do
    value { 'Yes' }
  end

  factory :array_response, parent: :framework_response, class: 'FrameworkResponse::Array' do
    association(:framework_question, :checkbox, options: ['Level 1', 'Level 2'])
    value { ['Level 1'] }
  end
end
