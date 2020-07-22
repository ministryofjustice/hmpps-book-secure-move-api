# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse do
  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to belong_to(:person_escort_record) }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }
  it { is_expected.to have_and_belong_to_many(:flags) }
  it { is_expected.to validate_presence_of(:type) }

  context 'with validations' do
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

  describe '#responded' do
    it 'sets the responded value to false on creation with empty value' do
      response = create(:string_response, value: nil)

      expect(response.responded).to be(false)
    end

    it 'sets the responded value to false on creation with value' do
      response = create(:string_response, value: 'Yes')

      expect(response.responded).to be(false)
    end

    it 'sets the responded value to true on update with empty value' do
      response = create(:string_response, value: nil)
      response.update(value: 'Yes')

      expect(response.responded).to be(true)
    end

    it 'sets the responded value to update on update with value' do
      response = create(:string_response, value: 'Yes')
      response.update(value: nil)

      expect(response.responded).to be(true)
    end
  end

  describe '#update_with_flags!' do
    it 'updates response value' do
      response = create(:string_response, value: nil)
      response.update_with_flags!('Yes')

      expect(response.value).to eq('Yes')
    end

    it 'does not attach flags if no flags attached to question' do
      create(:flag)
      response = create(:string_response)
      response.update_with_flags!('Yes')

      expect(response.flags).to be_empty
    end

    it 'does not attach flags if answer supplied does not match flag' do
      flag = create(:flag)
      response = create(:string_response, value: nil, framework_question: flag.framework_question)
      response.update_with_flags!('No')

      expect(response.flags).to be_empty
    end

    it 'attaches flags if answer supplied matches flag for string' do
      flag = create(:flag)
      response = create(:string_response, value: nil, framework_question: flag.framework_question)
      response.update_with_flags!('Yes')

      expect(response.flags).to contain_exactly(flag)
    end

    it 'attaches flags if answer supplied matches flag for array' do
      response = create(:array_response, value: nil)
      flag = create(:flag, question_value: 'Level 1', framework_question: response.framework_question)
      response.update_with_flags!(['Level 1', 'Level 2'])

      expect(response.flags).to contain_exactly(flag)
    end

    it 'attaches flags if answer supplied matches flag for object' do
      response = create(:object_response, :details, value: nil)
      flag = create(:flag, question_value: 'Yes', framework_question: response.framework_question)
      response.update_with_flags!({ option: 'Yes', details: 'something' })

      expect(response.flags).to contain_exactly(flag)
    end

    it 'attaches flags if answer supplied matches flag for collection' do
      response = create(:collection_response, :details, value: nil)
      flag = create(:flag, question_value: 'Level 1', framework_question: response.framework_question)
      response.update_with_flags!([{ option: 'Level 1', details: 'something' }])

      expect(response.flags).to contain_exactly(flag)
    end

    it 'attaches multiple flags if answer supplied matches flag' do
      framework_question = create(:framework_question)
      flag1 = create(:flag, framework_question: framework_question)
      flag2 = create(:flag, framework_question: framework_question)
      response = create(:string_response, value: nil, framework_question: framework_question)
      response.update_with_flags!('Yes')

      expect(response.flags).to contain_exactly(flag1, flag2)
    end

    it 'detaches flag if answer changed' do
      framework_question = create(:framework_question)
      flag1 = create(:flag, framework_question: framework_question)
      flag2 = create(:flag, framework_question: framework_question)
      response = create(:string_response, framework_question: framework_question, flags: [flag1, flag2])
      response.update_with_flags!('No')

      expect(response.reload.flags).to be_empty
    end

    it 'attaches another flag if answer changed' do
      framework_question = create(:framework_question)
      flag1 = create(:flag, framework_question: framework_question)
      flag2 = create(:flag, question_value: 'No', framework_question: framework_question)
      response = create(:string_response, framework_question: framework_question, flags: [flag1])
      response.update_with_flags!('No')

      expect(response.flags).to contain_exactly(flag2)
    end

    context 'when dependent responses' do
      it 'clears dependent responses if value changed' do
        parent_response = create(:string_response)
        child1_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        child2_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        create(:string_response, framework_question: child1_question, parent: parent_response)
        create(:string_response, framework_question: child2_question, parent: parent_response)
        parent_response.update_with_flags!('No')

        parent_response.dependents.each do |child_response|
          expect(child_response.reload.value).to be_nil
        end
      end

      it 'does not clear value of current response' do
        parent_response = create(:string_response)
        child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        create(:string_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!('No')

        expect(parent_response.reload.value).to eq('No')
      end

      it 'clears dependent responses if value changed on array' do
        parent_response = create(:array_response)
        child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:array_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(['Level 2'])

        expect(child_response.reload.value).to be_empty
      end

      it 'clears dependent responses if value changed on object' do
        parent_response = create(:object_response, :details)
        child_question = create(:framework_question, followup_comment: true, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response = create(:object_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(option: 'No')

        expect(child_response.reload.value).to be_empty
      end

      it 'clears dependent responses if value changed on collection' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!([option: 'Level 2'])

        expect(child_response.reload.value).to be_empty
      end

      it 'does not clear dependent responses if value similar' do
        parent_response = create(:string_response)
        child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response = create(:string_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!('Yes')

        expect(child_response.reload.value).to eq('Yes')
      end

      it 'does not clear dependent responses if value similar on array' do
        parent_response = create(:array_response)
        child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:array_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(['Level 1', 'Level 2'])

        expect(child_response.reload.value).to eq(['Level 1'])
      end

      it 'does not clear dependent responses if value similar on object' do
        parent_response = create(:object_response, :details)
        child_question = create(:framework_question, followup_comment: true, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response = create(:object_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(option: 'Yes')

        expect(child_response.reload.value).to eq('option' => 'Yes', 'details' => 'some comment')
      end

      it 'does not clear dependent responses if value similar on collection' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!([{ option: 'Level 1' }, { option: 'Level 2' }])

        expect(child_response.reload.value).to contain_exactly(
          { 'option' => 'Level 1', 'details' => 'some comment' },
          { 'option' => 'Level 2', 'details' => 'another comment' },
        )
      end

      it 'clears all hierarchy of dependent responses' do
        parent_response = create(:string_response)
        child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        grand_child_question = create(:framework_question, dependent_value: 'Yes', parent: child_question)
        child_response = create(:string_response, framework_question: child_question, parent: parent_response)
        grand_child_response = create(:string_response, framework_question: grand_child_question, parent: child_response)
        parent_response.update_with_flags!('No')

        expect(grand_child_response.reload.value).to be_nil
      end

      it 'clears only relevant dependent responses according to dependent value' do
        parent_response = create(:array_response)
        child1_question = create(:framework_question, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child2_question = create(:framework_question, dependent_value: 'Level 2', parent: parent_response.framework_question)
        create(:string_response, framework_question: child1_question, parent: parent_response)
        child_response = create(:string_response, framework_question: child2_question, parent: parent_response)
        parent_response.update_with_flags!(['Level 2'])

        expect(child_response.reload.value).to eq('Yes')
      end

      it 'does not clear dependent values if record invalid' do
        parent_response = create(:array_response)
        child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:array_response, framework_question: child_question, parent: parent_response)

        expect { parent_response.update_with_flags!('Level 2') }.to raise_error(ActiveRecord::RecordInvalid)
        expect(child_response.reload.value).to eq(['Level 1'])
      end

      it 'clears flags on dependent responses if value changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, flags: [create(:flag)])
        parent_response.update_with_flags!([option: 'Level 2'])

        expect(child_response.reload.flags).to be_empty
      end

      it 'does not clear flags on dependent responses if value not changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        flag = create(:flag)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, flags: [flag])
        parent_response.update_with_flags!([option: 'Level 1'])

        expect(child_response.reload.flags).to contain_exactly(flag)
      end

      it 'sets responded to false on dependent responses if value changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, flags: [create(:flag)], responded: true)
        parent_response.update_with_flags!([option: 'Level 2'])

        expect(child_response.reload.responded).to be(false)
      end

      it 'does not set responded to false on dependent responses if value not changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        flag = create(:flag)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, flags: [flag], responded: true)
        parent_response.update_with_flags!([option: 'Level 1'])

        expect(child_response.reload.responded).to be(true)
      end
    end
  end
end
