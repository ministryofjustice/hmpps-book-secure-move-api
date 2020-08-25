# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::Array do
  subject { create(:array_response) }

  context 'with validations' do
    it { is_expected.to validate_absence_of(:value_text) }

    it 'validates values included in options' do
      question = create(:framework_question, :checkbox)
      response = create(:array_response, value: ['Level 3', 'Level 4'], framework_question: question)

      expect(response).not_to be_valid
      expect(response.errors.messages[:value]).to eq(['Level 3, Level 4 are not valid options'])
    end

    it 'does not validate values if value included in options' do
      question = create(:framework_question, :checkbox)
      response = create(:array_response, value: ['Level 1', 'Level 2'], framework_question: question)

      expect(response).to be_valid
    end

    it 'validates correct type is passed in on creation' do
      question = create(:framework_question, :checkbox)

      expect { build(:array_response, framework_question: question, value: { 'option' => 'Level 4' }) }.to raise_error(ActiveModel::ValidationError, /Value is incorrect type/)
    end

    it 'validates correct type is passed in on update' do
      question = create(:framework_question, :checkbox)
      response = create(:array_response, framework_question: question)

      expect { response.update(value: { 'option' => 'Level 4' }) }.to raise_error(ActiveModel::ValidationError)
      expect(response.errors.messages[:value]).to contain_exactly('is incorrect type')
    end

    context 'when question required' do
      it 'validates presence of value when value is empty' do
        question = create(:framework_question, :checkbox, required: true)
        response = create(:array_response, value: [], framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when value is nil' do
        question = create(:framework_question, :checkbox, required: true)
        response = create(:array_response, value: nil, framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end
    end

    context 'when question not required' do
      it 'does not validate presence of value when value is empty' do
        question = create(:framework_question, :checkbox)
        response = create(:array_response, value: [], framework_question: question)

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is nil' do
        question = create(:framework_question, :checkbox)
        response = create(:array_response, value: nil, framework_question: question)

        expect(response).to be_valid
      end
    end

    context 'when dependent question' do
      it 'does not validate presence of value if parent not answered' do
        question = create(:framework_question, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: nil)
        response = create(:array_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'does not validate presence of value if parent answered with different answer' do
        question = create(:framework_question, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'No')
        response = create(:array_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'validates presence of value if parent answered with dependent value' do
        question = create(:framework_question, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:array_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'does not validate presence of value if parent answered with dependent value but question not required' do
        question = create(:framework_question, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:array_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end
    end
  end

  describe '#value' do
    it 'returns the response value if type is array' do
      response = create(
        :array_response,
        value: ['Level 1', 'Level 2'],
      )

      expect(response.value).to contain_exactly('Level 1', 'Level 2')
    end

    it 'returns an empty response value if set as empty' do
      response = create(:array_response, value: [])

      expect(response.value).to be_empty
    end

    it 'defaults to an empty response value if set to nil' do
      response = create(:array_response, value: nil)

      expect(response.value).to be_empty
    end
  end

  describe '#option_selected?' do
    it 'returns true if option matches any option selected' do
      response = create(
        :array_response,
        value: ['Level 1', 'Level 2'],
      )

      expect(response.option_selected?('Level 2')).to be(true)
    end

    it 'returns false if option does not match any option selected' do
      response = create(
        :array_response,
        value: ['Level 1', 'Level 2'],
      )

      expect(response.option_selected?('Level 3')).to be(false)
    end
  end
end
