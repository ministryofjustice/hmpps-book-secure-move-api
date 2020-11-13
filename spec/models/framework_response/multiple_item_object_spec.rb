# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::MultipleItemObject, type: :model do
  let(:person_escort_record) { create(:person_escort_record) }

  context 'with validations' do
    it 'ignores other keys passed in' do
      questions = [create(:framework_question)]
      attributes = { items: 1, responses: [{ value: 'Yes', framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:item]).to eq(["can't be blank", 'is not a number'])
    end

    it 'validates the presence of an item' do
      questions = [create(:framework_question)]
      attributes = { responses: [{ value: 'Yes', framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:item]).to eq(["can't be blank", 'is not a number'])
    end

    it 'validates that item attribute is a number' do
      questions = [create(:framework_question)]
      attributes = { item: 'some-item', responses: [{ value: 'Yes', framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:item]).to eq(['is not a number'])
    end

    it 'validates that item attribute is an integer' do
      questions = [create(:framework_question)]
      attributes = { item: 1.1, responses: [{ value: 'Yes', framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:item]).to eq(['must be an integer'])
    end

    it 'validates the presence of a responses key' do
      questions = [create(:framework_question)]
      attributes = { item: 1, response: [{ value: 'Yes', framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:responses]).to eq(["can't be blank"])
    end

    it 'validates responses if an item are not empty' do
      question1 = create(:framework_question, :checkbox)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:responses]).to eq(["can't be blank"])
    end

    it 'validates type of responses key' do
      questions = [create(:framework_question)]
      attributes = { item: 1, responses: { value: 'Yes', framework_question_id: questions.first.id } }

      expect { described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record) }.to raise_error(FrameworkResponse::ValueTypeError)
    end

    it 'validates responses include value key if multiple responses supplied and question required' do
      question1 = create(:framework_question, :checkbox, required: true)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id }, { framework_question_id: question1.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:"responses[1].value"]).to eq(["can't be blank"])
    end

    it 'does not validate responses include value key if multiple responses supplied and question not required' do
      question1 = create(:framework_question, :checkbox)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id }, { framework_question_id: question1.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).to be_valid
    end

    it 'validates responses include framework_question_id key if multiple responses supplied and question required' do
      question1 = create(:framework_question, :checkbox, required: true)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id }, { value: ['Level 1'] }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:responses]).to eq(['provide a value for all required questions'])
    end

    it 'does not validate responses include framework_question_id key if multiple responses supplied and question not required' do
      question1 = create(:framework_question, :checkbox)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id }, { value: ['Level 1'] }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).to be_valid
    end

    it 'ignores responses with framework_question_id not included in question ids' do
      question1 = create(:framework_question, :checkbox)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id }, { value: ['Level 1'], framework_question_id: 'some-id' }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).to be_valid
    end

    it 'ignores other keys in responses' do
      question1 = create(:framework_question, :checkbox)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id, values: 'Some value' }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).to be_valid
    end

    it 'validates response if value for response is invalid' do
      questions = [create(:framework_question, :checkbox)]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect { object.valid? }.to raise_error(FrameworkResponse::ValueTypeError)
    end

    it 'does not validate the response if value for response is valid' do
      questions = [create(:framework_question, :checkbox)]
      attributes = { item: 1, responses: [{ value: ['Level 1'], framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).to be_valid
    end

    it 'validates response if value for response is required' do
      questions = [create(:framework_question, :checkbox, required: true)]
      attributes = { item: 1, responses: [{ value: nil, framework_question_id: questions.first.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:"responses[0].value"]).to eq(["can't be blank"])
    end

    it 'validates required questions if no response provided for that question' do
      question1 = create(:framework_question, :checkbox, required: true)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).not_to be_valid
      expect(object.errors.messages[:responses]).to eq(['provide a value for all required questions'])
    end

    it 'does not validate optional question if no response provided for that question' do
      question1 = create(:framework_question, :checkbox)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = { item: 1, responses: [{ value: 'Yes', framework_question_id: question2.id }] }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object).to be_valid
    end
  end

  describe '#as_json' do
    it 'returns a hash of the item and responses' do
      question1 = create(:framework_question, :checkbox, required: true)
      question2 = create(:framework_question, required: true)
      questions = [question1, question2]
      attributes = {
        item: 1,
        responses: [
          { value: ['Level 1'], framework_question_id: question1.id },
          { value: 'No', framework_question_id: question2.id },
        ],
      }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object.as_json).to eq(attributes)
    end

    it 'returns an empty hash if nothing passed in' do
      questions = [create(:framework_question, :checkbox, required: true)]
      object = described_class.new(attributes: {}, questions: questions, assessmentable: person_escort_record)

      expect(object.as_json).to be_empty
    end

    it 'returns an empty hash if nil option and details passed in' do
      questions = [create(:framework_question, :checkbox, required: true)]
      attributes = {
        item: nil,
        responses: nil,
      }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object.as_json).to be_empty
    end

    it 'ignores invalid responses if no value supplied' do
      question1 = create(:framework_question, :checkbox, required: true)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = {
        item: 1,
        responses: [{ value: ['Level 1'], framework_question_id: question1.id }, { framework_question_id: question2.id }],
      }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object.as_json).to eq({
        item: 1,
        responses: [
          { value: ['Level 1'], framework_question_id: question1.id },
          { value: nil, framework_question_id: question2.id },
        ],
      })
    end

    it 'ignores invalid responses if no framework_question_id supplied' do
      question1 = create(:framework_question, :checkbox, required: true)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = {
        item: 1,
        responses: [{ value: ['Level 1'], framework_question_id: question1.id }, { value: 'Yes' }],
      }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object.as_json).to eq({
        item: 1,
        responses: [
          { value: ['Level 1'], framework_question_id: question1.id },
        ],
      })
    end

    it 'ignores invalid responses if framework_question_id supplied incorrect' do
      question1 = create(:framework_question, :checkbox, required: true)
      question2 = create(:framework_question)
      questions = [question1, question2]
      attributes = {
        item: 1,
        responses: [{ value: ['Level 1'], framework_question_id: question1.id }, { value: 'Yes', framework_question_id: 'some-id' }],
      }
      object = described_class.new(attributes: attributes, questions: questions, assessmentable: person_escort_record)

      expect(object.as_json).to eq({
        item: 1,
        responses: [
          { value: ['Level 1'], framework_question_id: question1.id },
        ],
      })
    end
  end
end
