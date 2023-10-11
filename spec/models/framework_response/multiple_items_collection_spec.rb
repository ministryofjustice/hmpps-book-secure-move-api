# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::MultipleItemsCollection, type: :model do
  let(:person_escort_record) { create(:person_escort_record) }

  context 'with validations' do
    it 'validates the object passed' do
      question1 = create(:framework_question, :checkbox)
      question2 = create(:framework_question)
      questions = [question1, question2]
      response1 = { value: ['Level 3'], framework_question_id: question1.id }
      response2 = { value: 'Yes', framework_question_id: question2.id }
      collection = [{ item: 1, responses: [response2] }, { item: 2, responses: [response1, response2] }]

      collection = described_class.new(collection:, assessmentable: person_escort_record, questions:)

      expect(collection).not_to be_valid
      expect(collection.errors.messages[:"items[1].responses[0].value"]).to eq(['Level 3 are not valid options'])
    end

    it 'validates the object type passed' do
      question = create(:framework_question, :checkbox)
      response = { value: 'Level 3', framework_question_id: question.id }
      collection = [{ item: 1, responses: [response] }]

      collection = described_class.new(collection:, assessmentable: person_escort_record, questions: [question])

      expect { collection.valid? }.to raise_error(FrameworkResponse::ValueTypeError)
    end
  end

  describe '#to_a' do
    it 'returns collection of multiple item objects' do
      question = create(:framework_question, :checkbox)
      response = { value: ['Level 1'], framework_question_id: question.id }
      collection = [{ item: 1, responses: [response] }]

      collection = described_class.new(collection:, assessmentable: person_escort_record, questions: [question])
      expect(collection.to_a.first).to be_a(FrameworkResponse::MultipleItemObject)
    end

    it 'maps collection of objects' do
      question = create(:framework_question, :checkbox)
      response1 = { value: ['Level 1'], framework_question_id: question.id }
      response2 = { value: ['Level 2'], framework_question_id: question.id }
      collection = [{ item: 1, responses: [response2] }, { item: 2, responses: [response1] }]

      collection = described_class.new(collection:, assessmentable: person_escort_record, questions: [question])
      expect(collection.to_a.count).to eq(2)
    end

    it 'returns an empty array if collection is empty' do
      collection = described_class.new(collection: [], assessmentable: person_escort_record)

      expect(collection.to_a).to be_empty
    end
  end
end
