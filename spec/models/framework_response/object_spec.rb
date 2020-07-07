# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::Object do
  subject { create(:object_response) }

  it { is_expected.to validate_absence_of(:value_text) }

  it 'validates presence of value when a record is updated if question is required' do
    question = create(:framework_question, required: true, options: [])
    response = create(:object_response, value: nil, framework_question: question)

    expect(response).not_to be_valid
  end

  it 'does not validate presence of value when a record is updated if question is required and dependent' do
    question = create(:framework_question, required: true, options: [])
    response = create(:object_response, value: nil, framework_question: question, parent: create(:string_response))

    expect(response).to be_valid
  end

  it 'does not validate presence of value when a record is updated if question is not required' do
    question = create(:framework_question, options: [])
    response = create(:object_response, value: nil, framework_question: question)

    expect(response).to be_valid
  end

  it 'validates presence of value when a record is updated if question and details are required' do
    question = create(:framework_question, required: true, options: [], followup_comment: true)
    response = create(:object_response, value: nil, framework_question: question)

    expect(response).not_to be_valid
  end

  it 'validates details object' do
    question = create(
      :framework_question,
      followup_comment: true,
      followup_comment_options: %w[Yes],
    )
    response = create(:object_response, :details, value: { 'option' => 'Yes' }, framework_question: question)

    expect(response).not_to be_valid
  end

  describe '#value' do
    it 'returns the response value as json' do
      response = create(
        :object_response,
        value: { name: 'some name' },
      )

      expect(response.value.as_json).to eq('name' => 'some name')
    end

    it 'returns an empty response value if set as empty' do
      response = create(:object_response, value: {})

      expect(response.value).to be_empty
    end

    it 'defaults to an empty response value if set to nil' do
      response = create(:object_response, value: nil)

      expect(response.value).to be_empty
    end

    it 'returns response value if details supplied' do
      response = create(:object_response, :details)

      expect(response.value.as_json).to eq('option' => 'Yes', 'details' => 'some comment')
    end

    it 'returns response value if details supplied but empty' do
      response = create(:object_response, :details, value: {})

      expect(response.value.as_json).to eq('option' => nil, 'details' => nil)
    end

    it 'returns response value if details supplied but nil' do
      response = create(:object_response, :details, value: nil)

      expect(response.value.as_json).to eq('option' => nil, 'details' => nil)
    end
  end

  describe '#option_selected?' do
    it 'returns true if option matches any option selected' do
      response = create(:object_response, :details)

      expect(response.option_selected?('Yes')).to be(true)
    end

    it 'returns false if option does not match any option selected' do
      response = create(:object_response, :details)

      expect(response.option_selected?('No')).to be(false)
    end
  end
end
