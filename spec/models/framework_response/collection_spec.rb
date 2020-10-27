# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse::Collection do
  subject { create(:collection_response) }

  context 'with validations' do
    it { is_expected.to validate_absence_of(:value_text) }

    it 'validates correct type is passed in' do
      response = create(:collection_response, :details)

      expect { response.update(value: { 'option' => 'Level 4' }) }.to raise_error(FrameworkResponse::ValueTypeError)
    end

    it 'validates correct type nested in array is passed in' do
      expect { build(:collection_response, :details, value: ['option', 'Level 4']) }.to raise_error(FrameworkResponse::ValueTypeError)
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

    it 'validates multiple items collection' do
      question = create(:framework_question, :add_multiple_items, required: true)
      response = create(
        :collection_response,
        :multiple_items,
        framework_question: question,
        value: [{ 'item' => 'Yes', responses: [{ 'value' => ['Level 1'], framework_question_id: question.dependents.first.id }] }],
      )

      expect(response).not_to be_valid
      expect(response.errors.messages[:"items[0].item"]).to eq(['is not a number'])
    end

    context 'when question required' do
      it 'validates presence of value when value is empty for details question' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true)
        response = create(:collection_response, :details, value: [], framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when value is empty for multiple items question' do
        question = create(:framework_question, :add_multiple_items, required: true)
        response = create(:collection_response, :multiple_items, value: [], framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when value is nil' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true)
        response = create(:collection_response, :details, value: nil, framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when empty option and detail supplied' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true)
        response = create(:collection_response, :details, value: [{ details: nil, option: nil }], framework_question: question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'validates presence of value when empty item and responses supplied' do
        framework_question = create(:framework_question, :add_multiple_items, required: true)
        response = create(:collection_response, :multiple_items, value: [{ item: nil, responses: nil }], framework_question: framework_question)

        expect(response).not_to be_valid
        expect(response.errors.messages[:value]).to eq(["can't be blank"])
      end

      it 'does not validate presence of value when value is provided for detail collection' do
        question = create(:framework_question, :checkbox, followup_comment: true, required: true)
        response = create(:collection_response, :details, value: [{ option: 'Level 1', details: 'some comment' }], framework_question: question)

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is provided for multiple item collection' do
        question = create(:framework_question, :add_multiple_items, required: true)
        response = create(:collection_response, :multiple_items, value: [{ item: 1, responses: [{ value: ['Level 1'], framework_question_id: question.dependents.first.id }] }], framework_question: question)

        expect(response).to be_valid
      end
    end

    context 'when question not required' do
      it 'does not validate presence of value when value is empty for details response' do
        response = create(:collection_response, :details, value: [])

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is empty for multiple item response' do
        response = create(:collection_response, :multiple_items, value: [])

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is nil' do
        response = create(:collection_response, :details, value: nil)

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is provided for details response' do
        response = create(:collection_response, :details, value: [{ option: 'Level 2', details: 'some comment' }])

        expect(response).to be_valid
      end

      it 'does not validate presence of value when value is provided for multiple response' do
        response = create(:collection_response, :multiple_items)

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

    context 'with NOMIS mappings' do
      it 'does not validate required followup comments if mappings present' do
        question = create(
          :framework_question,
          :checkbox,
          followup_comment: true,
          followup_comment_options: %w[Level 1],
        )
        response = create(:collection_response, :details, value: [{ 'option' => 'Level 1' }], framework_question: question, framework_nomis_mappings: [create(:framework_nomis_mapping)])

        expect(response).to be_valid
      end

      it 'does not validate optional followup comments if mappings present' do
        question = create(
          :framework_question,
          :checkbox,
          followup_comment: true,
          followup_comment_options: [],
        )
        response = create(:collection_response, :details, value: [{ 'option' => 'Level 1' }], framework_question: question, framework_nomis_mappings: [create(:framework_nomis_mapping)])

        expect(response).to be_valid
      end

      it 'does not validate optional followup comments if no mappings present' do
        question = create(
          :framework_question,
          :checkbox,
          followup_comment: true,
          followup_comment_options: [],
        )
        response = create(:collection_response, :details, value: [{ 'option' => 'Level 1' }], framework_question: question)

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

    context 'when details response' do
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

      it 'removes empty hashes in response' do
        collection = [
          { details: 'some comment', option: 'Level 1' },
          {},
          { details: nil, option: nil },
        ]
        response = create(:collection_response, :details, value: collection)

        expect(response.value.as_json).to contain_exactly(
          { 'details' => 'some comment', 'option' => 'Level 1' },
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

    context 'when multiple item response' do
      it 'returns response value if multiple items supplied' do
        response = create(:collection_response, :multiple_items)
        expect(response.value.as_json).to contain_exactly(
          { 'item' => 1, 'responses' => [{ 'value' => ['Level 1'], 'framework_question_id' => response.framework_question.dependents.first.id }] },
          { 'item' => 2, 'responses' => [{ 'value' => ['Level 2'], 'framework_question_id' => response.framework_question.dependents.first.id }] },
        )
      end

      it 'removes empty hashes in response' do
        question = create(:framework_question, :add_multiple_items)
        collection = [
          { 'item' => 1, 'responses' => [{ 'value' => ['Level 1'], 'framework_question_id' => question.dependents.first.id }] },
          {},
          { item: nil, responses: nil },
        ]
        response = create(:collection_response, :multiple_items, value: collection, framework_question: question)

        expect(response.value.as_json).to contain_exactly(
          { 'item' => 1, 'responses' => [{ 'value' => ['Level 1'], 'framework_question_id' => question.dependents.first.id }] },
        )
      end

      it 'returns response value if items supplied but empty' do
        response = create(:collection_response, :multiple_items, value: {})

        expect(response.value.as_json).to be_empty
      end

      it 'returns response value if items supplied but nil' do
        response = create(:collection_response, :multiple_items, value: nil)

        expect(response.value.as_json).to be_empty
      end
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

    it 'ignores multiple item type responses' do
      response = create(:collection_response, :multiple_items)

      expect(response.option_selected?('Level 3')).to be(false)
    end
  end

  describe '#prefill_value' do
    it 'returns default if collection not multiple items and question is not to be prefilled' do
      response = create(:collection_response, :details)

      expect(response.prefill_value).to be_nil
    end

    it 'returns default if collection not multiple items and question is to be prefilled' do
      framework_question = create(:framework_question, followup_comment: true, prefill: true)
      response = create(:collection_response, :details, framework_question: framework_question)

      expect(response.prefill_value).to eq([{ 'details' => 'some comment', 'option' => 'Level 1' }, { 'details' => 'another comment', 'option' => 'Level 2' }])
    end

    it 'returns nothing if no multiple item dependent questions should be prefilled' do
      dependent_question = create(:framework_question, :checkbox, prefill: false)
      question = create(:framework_question, :add_multiple_items, dependents: [dependent_question])
      response = create(
        :collection_response,
        :multiple_items,
        framework_question: question,
        value: [{ 'item' => '1', responses: [{ 'value' => ['Level 1'], framework_question_id: dependent_question.id }] }],
      )

      expect(response.prefill_value).to be_empty
    end

    it 'returns response value if all multiple item dependent questions should be prefilled' do
      dependent_question = create(:framework_question, :checkbox, prefill: true)
      question = create(:framework_question, :add_multiple_items, dependents: [dependent_question])
      value = [{ 'item' => '1', responses: [{ 'value' => ['Level 1'], framework_question_id: dependent_question.id }] }.with_indifferent_access]
      response = create(
        :collection_response,
        :multiple_items,
        framework_question: question,
        value: value,
      )

      expect(response.prefill_value).to eq(value)
    end

    it 'returns the response value of the multiple item dependent questions that should be prefilled' do
      dependent_question1 = create(:framework_question, :checkbox, prefill: true)
      dependent_question2 = create(:framework_question, prefill: false)
      question = create(:framework_question, :add_multiple_items, dependents: [dependent_question1, dependent_question2])
      value = [
        { 'item' => '1', responses: [{ 'value' => ['Level 1'], framework_question_id: dependent_question1.id }] },
        { 'item' => '2', responses: [{ 'value' => ['Level 2'], framework_question_id: dependent_question1.id }, { 'value' => 'Yes', framework_question_id: dependent_question2.id }] },
      ]
      response = create(:collection_response, :multiple_items, framework_question: question, value: value)

      expect(response.prefill_value).to eq(
        [
          { 'item' => '1', responses: [{ 'value' => ['Level 1'], framework_question_id: dependent_question1.id }] }.with_indifferent_access,
          { 'item' => '2', responses: [{ 'value' => ['Level 2'], framework_question_id: dependent_question1.id }] }.with_indifferent_access,
        ],
      )
    end
  end
end
