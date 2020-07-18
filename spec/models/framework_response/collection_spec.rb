# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::Collection do
  subject { create(:collection_response) }

  context 'with validations' do
    it { is_expected.to validate_absence_of(:value_text) }

    it 'validates correct type is passed in' do
      response = create(:collection_response, :details)
      response.update(value: { 'option' => 'Level 4' })

      expect(response).not_to be_valid
      expect(response.errors.messages[:value]).to eq(['is incorrect type'])
    end

    it 'validates correct type nested in array is passed in' do
      response = build(:collection_response, :details, value: ['option', 'Level 4'])

      expect(response).not_to be_valid
      expect(response.errors.messages[:value]).to eq(['is incorrect type'])
    end

    it 'validates details collection' do
      question = create(
        :framework_question,
        :checkbox,
        followup_comment: true,
        followup_comment_options: %w[Yes],
      )
      response = create(:collection_response, :details, value: [{ 'option' => 'Yes' }], framework_question: question)

      expect(response).not_to be_valid
      expect(response.errors.messages[:details]).to eq(["can't be blank"])
    end

    context 'when question required' do
      it 'validates presence of value when value is empty' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true)
        response = create(:collection_response, :details, value: [], framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when value is nil' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true)
        response = create(:collection_response, :details, value: nil, framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'does not validate presence of value when value is provided' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true)
        response = create(:collection_response, :details, value: [{ 'option': 'Level 1', details: 'some comment' }], framework_question: question)

        expect(response).to be_valid
      end
    end

    context 'when question not required' do
      it 'does not validate presence of value when value is empty' do
        response = create(:collection_response, :details, value: [])

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is nil' do
        response = create(:collection_response, :details, value: nil)

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is provided' do
        response = create(:collection_response, :details, value: [{ option: 'Level 2', details: 'some comment' }])

        expect(response).to be_valid
      end
    end

    context 'when dependent question' do
      it 'does not validate presence of value if parent not answered' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: nil)
        response = create(:collection_response, :details, value: [], framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'does not validate presence of value if parent answered with different answer' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'No')
        response = create(:collection_response, :details, value: [], framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'validates presence of value if parent answered with dependent value' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:collection_response, :details, value: [], framework_question: question, parent: parent_response)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'does not validate presence of value if parent answered with dependent value but question not required' do
        question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:collection_response, value: [], framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'does not validate presence of value of dependent response if supplied' do
        question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:collection_response, value: [{ option: 'Level 2', details: 'some comment' }], framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end
    end
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
      collection = [
        { details: 'some comment', option: 'Level 1' },
        { details: 'some comment', option: 'Level 2' },
      ]
      response = create(:collection_response, :details, value: collection)

      expect(response.value.as_json).to contain_exactly(
        { 'details' => 'some comment', 'option' => 'Level 1' },
        { 'details' => 'some comment', 'option' => 'Level 2' },
      )
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

  describe '#option_selected?' do
    it 'returns true if option matches any option selected' do
      response = create(:collection_response, :details)

      expect(response.option_selected?('Level 1')).to be(true)
    end

    it 'returns false if option does not match any option selected' do
      response = create(:collection_response, :details)

      expect(response.option_selected?('Level 3')).to be(false)
    end
  end
end
