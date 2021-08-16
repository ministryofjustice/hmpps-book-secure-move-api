# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponse do
  it { is_expected.to belong_to(:framework_question) }
  it { is_expected.to belong_to(:assessmentable).optional }
  it { is_expected.to belong_to(:parent).optional }

  it { is_expected.to have_many(:dependents) }
  it { is_expected.to have_many(:framework_nomis_codes).through(:framework_question) }
  it { is_expected.to have_and_belong_to_many(:framework_flags) }
  it { is_expected.to have_and_belong_to_many(:framework_nomis_mappings) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:value_type) }
  it { is_expected.to validate_presence_of(:section) }

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

    it 'validates multiple item collection dependent responses' do
      question = create(:framework_question, :add_multiple_items, dependent_value: 'Level 1', options: [], required: true)
      response = create(:collection_response, :multiple_items, value: nil, parent: create(:collection_response, :details), framework_question: question)

      expect(response).to validate_presence_of(:value).on(:update)
    end

    it 'does not validate multiple item collection dependent responses if parent response is not correct value' do
      question = create(:framework_question, :add_multiple_items, dependent_value: 'Level 3', options: [], required: true)
      response = create(:collection_response, :multiple_items, value: nil, parent: create(:collection_response, :details), framework_question: question)

      expect(response).not_to validate_presence_of(:value).on(:update)
    end
  end

  describe '#update_with_flags!' do
    it 'updates response value' do
      response = create(:string_response, value: nil)
      response.update_with_flags!(new_value: 'Yes')

      expect(response.value).to eq('Yes')
    end

    it 'updates responded by value' do
      response = create(:string_response, value: nil)
      response.update_with_flags!(new_value: 'Yes', responded_by: 'some-user')

      expect(response.responded_by).to eq('some-user')
    end

    it 'updates responded at value' do
      responded_at = Time.zone.parse('2010-06-21')
      response = create(:string_response, value: nil)
      response.update_with_flags!(new_value: 'Yes', responded_at: responded_at)

      expect(response.responded_at).to eq(responded_at)
    end

    it 'does not attach flags if no flags attached to question' do
      create(:framework_flag)
      response = create(:string_response)
      response.update_with_flags!(new_value: 'Yes')

      expect(response.framework_flags).to be_empty
    end

    it 'does not attach flags if answer supplied does not match flag' do
      flag = create(:framework_flag)
      response = create(:string_response, value: nil, framework_question: flag.framework_question)
      response.update_with_flags!(new_value: 'No')

      expect(response.framework_flags).to be_empty
    end

    it 'attaches flags if answer supplied matches flag for string' do
      flag = create(:framework_flag)
      response = create(:string_response, value: nil, framework_question: flag.framework_question)
      response.update_with_flags!(new_value: 'Yes')

      expect(response.framework_flags).to contain_exactly(flag)
    end

    it 'attaches flags if answer supplied matches flag for array' do
      response = create(:array_response, value: nil)
      flag = create(:framework_flag, question_value: 'Level 1', framework_question: response.framework_question)
      response.update_with_flags!(new_value: ['Level 1', 'Level 2'])

      expect(response.framework_flags).to contain_exactly(flag)
    end

    it 'attaches flags if answer supplied matches flag for object' do
      response = create(:object_response, :details, value: nil)
      flag = create(:framework_flag, question_value: 'Yes', framework_question: response.framework_question)
      response.update_with_flags!(new_value: { option: 'Yes', details: 'something' })

      expect(response.framework_flags).to contain_exactly(flag)
    end

    it 'attaches flags if answer supplied matches flag for collection' do
      response = create(:collection_response, :details, value: nil)
      flag = create(:framework_flag, question_value: 'Level 1', framework_question: response.framework_question)
      response.update_with_flags!(new_value: [{ option: 'Level 1', details: 'something' }])

      expect(response.framework_flags).to contain_exactly(flag)
    end

    it 'attaches multiple flags if answer supplied matches flag' do
      framework_question = create(:framework_question)
      flag1 = create(:framework_flag, framework_question: framework_question)
      flag2 = create(:framework_flag, framework_question: framework_question)
      response = create(:string_response, value: nil, framework_question: framework_question)
      response.update_with_flags!(new_value: 'Yes')

      expect(response.framework_flags).to contain_exactly(flag1, flag2)
    end

    it 'detaches flag if answer changed' do
      framework_question = create(:framework_question)
      flag1 = create(:framework_flag, framework_question: framework_question)
      flag2 = create(:framework_flag, framework_question: framework_question)
      response = create(:string_response, framework_question: framework_question, framework_flags: [flag1, flag2])
      response.update_with_flags!(new_value: 'No')

      expect(response.reload.framework_flags).to be_empty
    end

    it 'attaches another flag if answer changed' do
      framework_question = create(:framework_question)
      flag1 = create(:framework_flag, framework_question: framework_question)
      flag2 = create(:framework_flag, question_value: 'No', framework_question: framework_question)
      response = create(:string_response, framework_question: framework_question, framework_flags: [flag1])
      response.update_with_flags!(new_value: 'No')

      expect(response.framework_flags).to contain_exactly(flag2)
    end

    it 'raises an error if transaction fails twice' do
      response = create(:string_response, value: nil)
      allow(response).to receive(:update!).and_raise(ActiveRecord::PreparedStatementCacheExpired).twice

      expect { response.update_with_flags!(new_value: 'Yes') }.to raise_error(ActiveRecord::PreparedStatementCacheExpired)
    end

    it 'retries the transaction if it fails only once and saves response' do
      response = create(:string_response, value: nil)

      # Allow update to fail first time, and second time to complete transaction
      return_values = [:raise, true]
      allow(response).to receive(:update!).twice do
        return_value = return_values.shift
        return_value == :raise ? raise(ActiveRecord::PreparedStatementCacheExpired) : response.update(value: 'Yes')  # rubocop:disable Rails/SaveBang
      end

      response.update_with_flags!(new_value: 'Yes')

      expect(response.value).to eq('Yes')
    end

    context 'when dependent responses' do
      it 'clears dependent responses if value changed' do
        parent_response = create(:string_response)
        child1_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        child2_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response1 = create(:string_response, framework_question: child1_question, parent: parent_response)
        child_response2 = create(:string_response, framework_question: child2_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: 'No')

        [child_response1, child_response2].each do |response|
          expect(response.reload.value).to be_nil
        end
      end

      it 'does not clear value of current response' do
        parent_response = create(:string_response)
        child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        create(:string_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: 'No')

        expect(parent_response.reload.value).to eq('No')
      end

      it 'clears dependent responses if value changed on array' do
        parent_response = create(:array_response)
        child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:array_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: ['Level 2'])

        expect(child_response.reload.value).to be_empty
      end

      it 'clears dependent responses if value changed on object' do
        parent_response = create(:object_response, :details)
        child_question = create(:framework_question, followup_comment: true, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response = create(:object_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: { option: 'No' })

        expect(child_response.reload.value).to be_empty
      end

      it 'clears dependent responses if value changed on collection' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: [option: 'Level 2'])

        expect(child_response.reload.value).to be_empty
      end

      it 'does not clear dependent responses if value similar' do
        parent_response = create(:string_response)
        child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response = create(:string_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: 'Yes')

        expect(child_response.reload.value).to eq('Yes')
      end

      it 'does not clear dependent responses if value similar on array' do
        parent_response = create(:array_response)
        child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:array_response, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: ['Level 1', 'Level 2'])

        expect(child_response.reload.value).to eq(['Level 1'])
      end

      it 'does not clear dependent responses if value similar on object' do
        parent_response = create(:object_response, :details)
        child_question = create(:framework_question, followup_comment: true, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response = create(:object_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: { option: 'Yes' })

        expect(child_response.reload.value).to eq('option' => 'Yes', 'details' => 'some comment')
      end

      it 'does not clear dependent responses if value similar on collection' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: [{ option: 'Level 1' }, { option: 'Level 2' }])

        expect(child_response.reload.value).to contain_exactly(
          { 'option' => 'Level 1', 'details' => 'some comment' },
          { 'option' => 'Level 2', 'details' => 'another comment' },
        )
      end

      it 'clears all hierarchy of dependent responses' do
        parent_response = create(:string_response)
        child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
        grand_child_question1 = create(:framework_question, dependent_value: 'Yes', parent: child_question)
        grand_child_question2 = create(:framework_question, dependent_value: 'No', parent: child_question)
        child_response = create(:string_response, framework_question: child_question, parent: parent_response)
        grand_child_response1 = create(:string_response, framework_question: grand_child_question1, parent: child_response)
        grand_child_response2 = create(:string_response, framework_question: grand_child_question2, parent: child_response)
        parent_response.update_with_flags!(new_value: 'No')

        [grand_child_response1, grand_child_response2].each do |response|
          expect(response.reload.value).to be_nil
        end
      end

      it 'clears only relevant dependent responses according to dependent value' do
        parent_response = create(:array_response)
        child1_question = create(:framework_question, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child2_question = create(:framework_question, dependent_value: 'Level 2', parent: parent_response.framework_question)
        create(:string_response, framework_question: child1_question, parent: parent_response)
        child_response = create(:string_response, framework_question: child2_question, parent: parent_response)
        parent_response.update_with_flags!(new_value: ['Level 2'])

        expect(child_response.reload.value).to eq('Yes')
      end

      it 'does not clear dependent values if record invalid' do
        parent_response = create(:array_response)
        child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:array_response, framework_question: child_question, parent: parent_response)

        expect { parent_response.update_with_flags!(new_value: 'Level 2') }.to raise_error(FrameworkResponse::ValueTypeError)
        expect(child_response.reload.value).to eq(['Level 1'])
      end

      it 'clears flags on dependent responses if value changed' do
        parent_response = create(:string_response)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Yes', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, framework_flags: [create(:framework_flag)])
        parent_response.update_with_flags!(new_value: 'No')

        expect(child_response.reload.framework_flags).to be_empty
      end

      it 'does not clear flags on dependent responses if value not changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        flag = create(:framework_flag)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, framework_flags: [flag])
        parent_response.update_with_flags!(new_value: [option: 'Level 1'])

        expect(child_response.reload.framework_flags).to contain_exactly(flag)
      end

      it 'sets responded to false on dependent responses if value changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, responded: true)
        parent_response.update_with_flags!(new_value: [option: 'Level 2'])

        expect(child_response.reload.responded).to be(false)
      end

      it 'does not set responded to false on dependent responses if value not changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, responded: true)
        parent_response.update_with_flags!(new_value: [option: 'Level 1'])

        expect(child_response.reload.responded).to be(true)
      end

      it 'sets prefilled to false on dependent responses if value changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, responded: true, prefilled: true)
        parent_response.update_with_flags!(new_value: [option: 'Level 2'])

        expect(child_response.reload.prefilled).to be(false)
      end

      it 'does not set prefilled to false on dependent responses if value not changed' do
        parent_response = create(:collection_response, :details)
        child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
        child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, responded: true, prefilled: true)
        parent_response.update_with_flags!(new_value: [option: 'Level 1'])

        expect(child_response.reload.prefilled).to be(true)
      end
    end

    context 'with person_escort_record status' do
      it 'does not change person escort record status answers provided invalid' do
        response = create(:string_response, value: nil)

        expect { response.update_with_flags!(new_value: %w[Yes]) }.to raise_error(FrameworkResponse::ValueTypeError)
        expect(response.assessmentable).to be_unstarted
      end

      it 'updates person escort record status if some answers provided' do
        response1 = create(:string_response, value: nil)
        create(:string_response, value: nil, assessmentable: response1.assessmentable)
        response1.update_with_flags!(new_value: 'Yes')

        expect(response1.assessmentable).to be_in_progress
      end

      it 'updates person escort record progress' do
        question = create(:framework_question, section: 'risk-information')
        response = create(:string_response, value: nil, framework_question: question)
        response.update_with_flags!(new_value: 'Yes')

        expect(response.reload.assessmentable.section_progress).to contain_exactly(
          { 'key' => 'risk-information', 'status' => 'completed' },
        )
      end

      it 'does not allow updating responses if person_escort_record status is confirmed' do
        person_escort_record = create(:person_escort_record, :confirmed, :with_responses)
        response = person_escort_record.framework_responses.first

        expect { response.update_with_flags!(new_value: 'No') }.to raise_error(ActiveRecord::ReadOnlyRecord)
        expect(response.reload.value).to eq('Yes')
      end
    end
  end

  describe '#prefill_value' do
    it 'returns the value of the response if response should be prefilled' do
      question = create(:framework_question, prefill: true)
      response = create(:string_response, framework_question: question, value: 'No')

      expect(response.prefill_value).to eq('No')
    end

    it 'does not return the value of the response if response should not be prefilled' do
      response = create(:string_response, value: 'No')

      expect(response.prefill_value).to be_nil
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
      response.update!(value: 'Yes')

      expect(response.responded).to be(true)
    end

    it 'sets the responded value to true on update with value' do
      response = create(:string_response, value: 'Yes')
      response.update!(value: nil)

      expect(response.responded).to be(true)
    end

    it 'sets the responded value to true on update with a prefilled value' do
      response = create(:string_response, value: 'Yes', prefilled: true, responded: false)
      response.update!(value: 'Yes')

      expect(response.responded).to be(true)
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

    it 'returns true if question required, value is empty and is not dependent' do
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
end
