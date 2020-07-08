# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse do
  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to belong_to(:person_escort_record) }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }

  it 'validates string dependent responses' do
    question = create(:framework_question, dependent_value: 'Yes', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:string_response), framework_question: question)

    expect(response).to validate_presence_of(:value).on(:update)
  end

  it 'does not validate string dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'No', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:string_response), framework_question: question)

    expect(response).not_to validate_presence_of(:value).on(:update)
  end

  it 'does not validate dependent responses if parent response is correct value but not required' do
    question = create(:framework_question, dependent_value: 'Yes', options: [], required: false)
    response = create(:string_response, value: nil, parent: create(:string_response), framework_question: question)

    expect(response).not_to validate_presence_of(:value).on(:update)
  end

  it 'validates array dependent responses' do
    question = create(:framework_question, dependent_value: 'Level 1', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:array_response), framework_question: question)

    expect(response).to validate_presence_of(:value).on(:update)
  end

  it 'does not validate array dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'Level 2', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:array_response), framework_question: question)

    expect(response).not_to validate_presence_of(:value).on(:update)
  end

  it 'validates object dependent responses' do
    question = create(:framework_question, dependent_value: 'Yes', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:object_response, :details), framework_question: question)

    expect(response).to validate_presence_of(:value).on(:update)
  end

  it 'does not validate object dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'No', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:object_response, :details), framework_question: question)

    expect(response).not_to validate_presence_of(:value).on(:update)
  end

  it 'validates collection dependent responses' do
    question = create(:framework_question, dependent_value: 'Level 1', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:collection_response, :details), framework_question: question)

    expect(response).to validate_presence_of(:value).on(:update)
  end

  it 'does not validate collection dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'Level 3', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:collection_response, :details), framework_question: question)

    expect(response).not_to validate_presence_of(:value).on(:update)
  end

  describe '.requires_value?' do
    it 'returns false if value present' do
      question = create(:framework_question, dependent_value: 'Yes', options: [], required: true)
      response = create(:string_response, value: 'some value', parent: create(:string_response), framework_question: question)

      expect(described_class.requires_value?(response.value, response)).to be(false)
    end

    it 'returns false if question not required' do
      question = create(:framework_question, options: [], required: false)
      response = create(:string_response, value: nil, framework_question: question)

      expect(described_class.requires_value?(response.value, response)).to be(false)
    end

    it 'returns true if question required, value is empty and has is not dependent' do
      question = create(:framework_question, options: [], required: true)
      response = create(:string_response, value: nil, framework_question: question)

      expect(described_class.requires_value?(response.value, response)).to be(true)
    end

    it 'returns true if record is dependent, required and missing value' do
      question = create(:framework_question, dependent_value: 'Yes', options: [], required: true)
      response = create(:string_response, value: nil, parent: create(:string_response), framework_question: question)

      expect(described_class.requires_value?(response.value, response)).to be(true)
    end

    it 'returns false if record is dependent but parent response does not match' do
      question = create(:framework_question, dependent_value: 'Yes', options: [], required: true)
      parent_response = create(:string_response, value: 'No')
      response = create(:string_response, value: nil, parent: parent_response, framework_question: question)

      expect(described_class.requires_value?(response.value, response)).to be(false)
    end
  end
end
