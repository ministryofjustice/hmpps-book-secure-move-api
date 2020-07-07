# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::String do
  subject { create(:string_response) }

  it { is_expected.to validate_absence_of(:value_json) }
  it { is_expected.to validate_inclusion_of(:value_text).in_array(%w[Yes No]) }

  it 'validates value text presence when a record is updated if question required' do
    question = create(:framework_question, required: true)
    response = create(:string_response, value: nil, framework_question: question)

    expect(response).to validate_presence_of(:value_text).on(:update)
  end

  it 'does not validate value text presence when a record is updated if question required and dependent' do
    question = create(:framework_question, required: true)
    response = create(:string_response, value: nil, framework_question: question, parent: create(:string_response))

    expect(response).not_to validate_presence_of(:value_text).on(:update)
  end

  it 'does not validates value text inclusion if no options present on question' do
    question = create(:framework_question, required: true, options: [])
    response = create(:string_response, value: 'Some value', framework_question: question)

    expect(response).not_to validate_inclusion_of(:value_text).in_array([])
  end

  describe '#value' do
    it 'returns the response value if type is string' do
      response = create(:string_response, value: 'Yes')

      expect(response.value).to eq('Yes')
    end

    it 'returns a nil response value if type is string and its empty' do
      response = create(:string_response, value: nil)

      expect(response.value).to be_nil
    end
  end

  describe '#option_selected?' do
    it 'returns true if option matches any option selected' do
      response = create(:string_response)

      expect(response.option_selected?('Yes')).to be(true)
    end

    it 'returns false if option does not match any option selected' do
      response = create(:string_response)

      expect(response.option_selected?('No')).to be(false)
    end
  end
end
