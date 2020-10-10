# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::Object do
  subject { create(:object_response) }

  context 'with validations' do
    it { is_expected.to validate_absence_of(:value_text) }

    it 'validates correct type is passed in on creation' do
      expect { build(:object_response, :details, value: ['Level 4']) }.to raise_error(FrameworkResponse::ValueTypeError)
    end

    it 'validates correct type is passed in on update' do
      response = create(:object_response, :details)

      expect { response.update(value: ['Level 4']) }.to raise_error(FrameworkResponse::ValueTypeError)
    end

    it 'validates details object' do
      question = create(
        :framework_question,
        followup_comment: true,
        followup_comment_options: %w[Yes],
      )
      response = create(:object_response, :details, value: { 'option' => 'Yes' }, framework_question: question)

      expect(response).not_to be_valid
      expect(response.errors.messages[:details]).to eq(["can't be blank"])
    end

    it 'validates details object missing keys' do
      question = create(
        :framework_question,
        followup_comment: true,
        followup_comment_options: %w[Yes],
      )
      response = create(:object_response, :details, value: { 'options' => 'Yes', 'details' => 'something' }, framework_question: question)

      expect(response).not_to be_valid
      expect(response.errors.messages[:option]).to eq(["can't be blank"])
    end

    context 'when question required' do
      it 'validates presence of value when value is empty' do
        question = create(:framework_question, followup_comment: true, required: true)
        response = create(:object_response, value: {}, framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when value is nil' do
        question = create(:framework_question, followup_comment: true, required: true)
        response = create(:object_response, value: nil, framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'does not validate presence of value when value is provided' do
        question = create(:framework_question, followup_comment: true, required: true)
        response = create(:object_response, :details, value: { option: 'Yes', details: 'some comment' }, framework_question: question)

        expect(response).to be_valid
      end
    end

    context 'when question not required' do
      it 'does not validate presence of value when value is empty' do
        response = create(:object_response, :details, value: {})

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is nil' do
        response = create(:object_response, :details, value: nil)

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is provided' do
        response = create(:object_response, :details, value: { option: 'Yes', details: 'some comment' })

        expect(response).to be_valid
      end
    end

    context 'when dependent question' do
      it 'does not validate presence of value if parent not answered' do
        question = create(:framework_question, followup_comment: true, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: nil)
        response = create(:object_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'does not validate presence of value if parent answered with different answer' do
        question = create(:framework_question, followup_comment: true, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'No')
        response = create(:object_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end

      it 'validates presence of value if parent answered with dependent value' do
        question = create(:framework_question, followup_comment: true, required: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:object_response, value: {}, framework_question: question, parent: parent_response)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'does not validate presence of value if parent answered with dependent value but question not required' do
        question = create(:framework_question, followup_comment: true, dependent_value: 'Yes')
        parent_response = create(:string_response, value: 'Yes')
        response = create(:object_response, value: nil, framework_question: question, parent: parent_response)

        expect(response).to be_valid
      end
    end

    context 'with NOMIS mappings' do
      it 'does not validate required followup comments if mappings present' do
        question = create(
          :framework_question,
          followup_comment: true,
          followup_comment_options: %w[Yes],
        )
        response = create(:object_response, :details, value: { 'option' => 'Yes' }, framework_question: question, framework_nomis_mappings: [create(:framework_nomis_mapping)])

        expect(response).to be_valid
      end

      it 'does not validate optional followup comments if mappings present' do
        question = create(
          :framework_question,
          followup_comment: true,
          followup_comment_options: [],
        )
        response = create(:object_response, :details, value: { 'option' => 'Yes' }, framework_question: question, framework_nomis_mappings: [create(:framework_nomis_mapping)])

        expect(response).to be_valid
      end

      it 'does not validate optional followup comments if no mappings present' do
        question = create(
          :framework_question,
          followup_comment: true,
          followup_comment_options: [],
        )
        response = create(:object_response, :details, value: { 'option' => 'Yes' }, framework_question: question)

        expect(response).to be_valid
      end
    end
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

      expect(response.value.as_json).to be_empty
    end

    it 'returns response value if details supplied but nil' do
      response = create(:object_response, :details, value: nil)

      expect(response.value.as_json).to be_empty
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
