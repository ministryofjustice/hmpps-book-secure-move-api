# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::String do
  subject { create(:string_response) }

  context 'with validations' do
    it { is_expected.to validate_absence_of(:value_json) }

    it 'validates values included in options' do
      response = build(:string_response, value: 'Some other value')

      expect(response).not_to be_valid
      expect(response.errors.messages[:value]).to eq(['is not included in the list'])
    end

    it 'does not validate values if value included in options' do
      response = create(:string_response, value: 'No')

      expect(response).to be_valid
    end

    it 'does not validate values if no options available' do
      question = create(:framework_question, :text)
      response = create(:string_response, value: 'Some value', framework_question: question)

      expect(response).to be_valid
    end

    it 'validates correct type is passed in on creation' do
      expect { build(:string_response, value: { 'option' => 'some option' }) }.to raise_error(FrameworkResponse::ValueTypeError)
    end

    it 'validates correct type is passed in on update' do
      response = create(:string_response)

      expect { response.update(value: { 'option' => 'some option' }) }.to raise_error(FrameworkResponse::ValueTypeError)
    end

    context 'when question required' do
      it 'validates presence of value when value is nil with options' do
        question = create(:framework_question, required: true)
        response = create(:string_response, value: nil, framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when value is nil with no options' do
        question = create(:framework_question, :text, required: true)
        response = create(:string_response, value: nil, framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end
    end

    context 'when question not required' do
      it 'does not validate presence of value when value is nil with options' do
        response = create(:string_response, value: nil)

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is nil with no options' do
        question = create(:framework_question, :text)
        response = create(:string_response, value: nil, framework_question: question)

        expect(response).to be_valid
      end
    end

    context 'when dependent question' do
      it 'does not validate presence of value if parent not answered' do
        question = create(:framework_question, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: nil)
        response = create(:string_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'does not validate presence of value if parent answered with different answer' do
        question = create(:framework_question, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'No')
        response = create(:string_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'validates presence of value if parent answered with dependent value' do
        question = create(:framework_question, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:string_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'does not validate presence of value if parent answered with dependent value but question not required' do
        question = create(:framework_question, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:string_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end
    end
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
