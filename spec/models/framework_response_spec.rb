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

    expect(response).not_to be_valid
  end

  it 'does not validate string dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'No', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:string_response), framework_question: question)

    expect(response).to be_valid
  end

  it 'does not validate dependent responses if parent response is correct value but not required' do
    question = create(:framework_question, dependent_value: 'Yes', options: [], required: false)
    response = create(:string_response, value: nil, parent: create(:string_response), framework_question: question)

    expect(response).to be_valid
  end

  it 'validates array dependent responses' do
    question = create(:framework_question, dependent_value: 'Level 1', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:array_response), framework_question: question)

    expect(response).not_to be_valid
  end

  it 'does not validate array dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'Level 2', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:array_response), framework_question: question)

    expect(response).to be_valid
  end

  it 'validates object dependent responses' do
    question = create(:framework_question, dependent_value: 'Yes', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:object_response, :details), framework_question: question)

    expect(response).not_to be_valid
  end

  it 'does not validate object dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'No', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:object_response, :details), framework_question: question)

    expect(response).to be_valid
  end

  it 'validates collection dependent responses' do
    question = create(:framework_question, dependent_value: 'Level 1', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:collection_response, :details), framework_question: question)

    expect(response).not_to be_valid
  end

  it 'does not validate collection dependent responses if parent response is not correct value' do
    question = create(:framework_question, dependent_value: 'Level 3', options: [], required: true)
    response = create(:string_response, value: nil, parent: create(:collection_response, :details), framework_question: question)

    expect(response).to be_valid
  end

  it 'sets correct type to framework response when object' do
    create(:object_response)

    expect(described_class.first).to be_a(FrameworkResponse::Object)
  end

  it 'sets correct type to framework response when collection' do
    create(:collection_response)

    expect(described_class.first).to be_a(FrameworkResponse::Collection)
  end

  it 'sets correct type to framework response when string' do
    create(:string_response)

    expect(described_class.first).to be_a(FrameworkResponse::String)
  end

  it 'sets correct type to framework response when array' do
    create(:array_response)

    expect(described_class.first).to be_a(FrameworkResponse::Array)
  end
end
