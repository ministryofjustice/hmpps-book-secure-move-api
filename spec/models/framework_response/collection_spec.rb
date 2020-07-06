# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::Collection do
  subject { create(:collection_response) }

  it { is_expected.to validate_absence_of(:value_text) }

  it 'validates presence of value when a record is updated if question is required' do
    question = create(:framework_question, required: true, options: [])
    response = create(:collection_response, value: nil, framework_question: question)

    expect(response).not_to be_valid
  end

  it 'does not validate presence of value when a record is updated if question is not required' do
    question = create(:framework_question, options: [])
    response = create(:collection_response, value: nil, framework_question: question)

    expect(response).to be_valid
  end

  it 'validates presence of value when a record is updated if question and details are required' do
    question = create(:framework_question, required: true, options: [], followup_comment: true)
    response = create(:collection_response, value: nil, framework_question: question)

    expect(response).not_to be_valid
  end

  it 'validates details collection' do
    question = create(
      :framework_question,
      followup_comment: true,
      followup_comment_options: %w[Yes],
    )
    response = create(:collection_response, :details, value: [{ 'option' => 'Yes' }], framework_question: question)

    expect(response).not_to be_valid
  end

  describe '#value' do
    it 'returns the response value as an array' do
      response = create(
        :collection_response,
        value: [{ name: 'some name' }],
      )

      expect(response.value.as_json).to contain_exactly('name' => 'some name')
    end

    it 'returns an empty response value if set as empty' do
      response = create(:collection_response, value: [])

      expect(response.value).to be_empty
    end

    it 'defaults to an empty response value if set to nil' do
      response = create(:collection_response, value: nil)

      expect(response.value).to be_empty
    end

    it 'returns response value if details supplied' do
      collection = [{ details: 'some comment', option: 'Level 1' }]
      response = create(:collection_response, :details, value: collection)

      expect(response.value.as_json).to contain_exactly('details' => 'some comment', 'option' => 'Level 1')
    end

    it 'returns response value if details supplied but empty' do
      response = create(:collection_response, :details, value: {})

      expect(response.value.as_json).to be_empty
    end

    it 'returns response value if details supplied but nil' do
      response = create(:collection_response, :details, value: nil)

      expect(response.value.as_json).to be_empty
    end
  end
end
