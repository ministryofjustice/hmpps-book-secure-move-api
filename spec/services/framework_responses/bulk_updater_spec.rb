# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponses::BulkUpdater do
  it 'updates response value' do
    per = create(:person_escort_record)
    response = create(:string_response, person_escort_record: per, value: nil)
    described_class.new(per, { response.id => 'Yes' }).call

    expect(response.reload.value).to eq('Yes')
  end

  it 'does not attach flags if no flags attached to question' do
    per = create(:person_escort_record)
    create(:framework_flag)
    response = create(:string_response, person_escort_record: per)
    described_class.new(per, { response.id => 'Yes' }).call

    expect(response.reload.framework_flags).to be_empty
  end

  it 'does not attach flags if answer supplied does not match flag' do
    per = create(:person_escort_record)
    flag = create(:framework_flag)
    response = create(:string_response, value: nil, framework_question: flag.framework_question, person_escort_record: per)
    described_class.new(per, { response.id => 'No' }).call

    expect(response.reload.framework_flags).to be_empty
  end

  it 'attaches flags if answer supplied matches flag for string' do
    per = create(:person_escort_record)
    flag = create(:framework_flag)
    response = create(:string_response, value: nil, framework_question: flag.framework_question, person_escort_record: per)
    described_class.new(per, { response.id => 'Yes' }).call

    expect(response.reload.framework_flags).to contain_exactly(flag)
  end

  it 'attaches flags if answer supplied matches flag for array' do
    per = create(:person_escort_record)
    response = create(:array_response, value: nil, person_escort_record: per)
    flag = create(:framework_flag, question_value: 'Level 1', framework_question: response.framework_question)
    described_class.new(per, { response.id => ['Level 1', 'Level 2'] }).call

    expect(response.reload.framework_flags).to contain_exactly(flag)
  end

  it 'attaches flags if answer supplied matches flag for object' do
    per = create(:person_escort_record)
    response = create(:object_response, :details, value: nil, person_escort_record: per)
    flag = create(:framework_flag, question_value: 'Yes', framework_question: response.framework_question)
    described_class.new(per, { response.id => { option: 'Yes', details: 'something' } }).call

    expect(response.reload.framework_flags).to contain_exactly(flag)
  end

  it 'attaches flags if answer supplied matches flag for collection' do
    per = create(:person_escort_record)
    response = create(:collection_response, :details, value: nil, person_escort_record: per)
    flag = create(:framework_flag, question_value: 'Level 1', framework_question: response.framework_question)
    described_class.new(per, { response.id => [{ option: 'Level 1', details: 'something' }] }).call

    expect(response.reload.framework_flags).to contain_exactly(flag)
  end

  it 'attaches multiple flags if answer supplied matches flag' do
    per = create(:person_escort_record)
    framework_question = create(:framework_question)
    flag1 = create(:framework_flag, framework_question: framework_question)
    flag2 = create(:framework_flag, framework_question: framework_question)
    response = create(:string_response, value: nil, framework_question: framework_question, person_escort_record: per)
    described_class.new(per, { response.id => 'Yes' }).call

    expect(response.reload.framework_flags).to contain_exactly(flag1, flag2)
  end

  it 'detaches flag if answer changed' do
    per = create(:person_escort_record)
    framework_question = create(:framework_question)
    flag1 = create(:framework_flag, framework_question: framework_question)
    flag2 = create(:framework_flag, framework_question: framework_question)
    response = create(:string_response, framework_question: framework_question, framework_flags: [flag1, flag2], person_escort_record: per)
    described_class.new(per, { response.id => 'No' }).call

    expect(response.reload.framework_flags).to be_empty
  end

  it 'attaches another flag if answer changed' do
    per = create(:person_escort_record)
    framework_question = create(:framework_question)
    flag1 = create(:framework_flag, framework_question: framework_question)
    flag2 = create(:framework_flag, question_value: 'No', framework_question: framework_question)
    response = create(:string_response, framework_question: framework_question, framework_flags: [flag1], person_escort_record: per)
    described_class.new(per, { response.id => 'No' }).call

    expect(response.reload.framework_flags).to contain_exactly(flag2)
  end

  context 'when dependent responses' do
    it 'clears dependent responses if value changed' do
      per = create(:person_escort_record)
      parent_response = create(:string_response, person_escort_record: per)
      child1_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
      child2_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
      child_response1 = create(:string_response, framework_question: child1_question, parent: parent_response, person_escort_record: per)
      child_response2 = create(:string_response, framework_question: child2_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => 'No' }).call

      [child_response1, child_response2].each do |response|
        expect(response.reload.value).to be_nil
      end
    end

    it 'does not clear value of current response' do
      per = create(:person_escort_record)
      parent_response = create(:string_response, person_escort_record: per)
      child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
      create(:string_response, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => 'No' }).call

      expect(parent_response.reload.value).to eq('No')
    end

    it 'clears dependent responses if value changed on array' do
      per = create(:person_escort_record)
      parent_response = create(:array_response, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:array_response, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => ['Level 2'] }).call

      expect(child_response.reload.value).to be_empty
    end

    it 'clears dependent responses if value changed on object' do
      per = create(:person_escort_record)
      parent_response = create(:object_response, :details, person_escort_record: per)
      child_question = create(:framework_question, followup_comment: true, dependent_value: 'Yes', parent: parent_response.framework_question)
      child_response = create(:object_response, :details, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => { option: 'No' } }).call

      expect(child_response.reload.value).to be_empty
    end

    it 'clears dependent responses if value changed on collection' do
      per = create(:person_escort_record)
      parent_response = create(:collection_response, :details, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => [option: 'Level 2'] }).call

      expect(child_response.reload.value).to be_empty
    end

    it 'does not clear dependent responses if value similar' do
      per = create(:person_escort_record)
      parent_response = create(:string_response, person_escort_record: per)
      child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
      child_response = create(:string_response, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => 'Yes' }).call

      expect(child_response.reload.value).to eq('Yes')
    end

    it 'does not clear dependent responses if value similar on array' do
      per = create(:person_escort_record)
      parent_response = create(:array_response, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:array_response, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => ['Level 1', 'Level 2'] }).call

      expect(child_response.reload.value).to eq(['Level 1'])
    end

    it 'does not clear dependent responses if value similar on object' do
      per = create(:person_escort_record)
      parent_response = create(:object_response, :details, person_escort_record: per)
      child_question = create(:framework_question, followup_comment: true, dependent_value: 'Yes', parent: parent_response.framework_question)
      child_response = create(:object_response, :details, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => { option: 'Yes' } }).call

      expect(child_response.reload.value).to eq('option' => 'Yes', 'details' => 'some comment')
    end

    it 'does not clear dependent responses if value similar on collection' do
      per = create(:person_escort_record)
      parent_response = create(:collection_response, :details, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => [{ option: 'Level 1' }, { option: 'Level 2' }] }).call

      expect(child_response.reload.value).to contain_exactly(
        { 'option' => 'Level 1', 'details' => 'some comment' },
        { 'option' => 'Level 2', 'details' => 'another comment' },
      )
    end

    it 'clears all hierarchy of dependent responses' do
      per = create(:person_escort_record)
      parent_response = create(:string_response, person_escort_record: per)
      child_question = create(:framework_question, dependent_value: 'Yes', parent: parent_response.framework_question)
      grand_child_question1 = create(:framework_question, dependent_value: 'Yes', parent: child_question)
      grand_child_question2 = create(:framework_question, dependent_value: 'No', parent: child_question)
      child_response = create(:string_response, framework_question: child_question, parent: parent_response, person_escort_record: per)
      grand_child_response1 = create(:string_response, framework_question: grand_child_question1, parent: child_response, person_escort_record: per)
      grand_child_response2 = create(:string_response, framework_question: grand_child_question2, parent: child_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => 'No' }).call

      [grand_child_response1, grand_child_response2].each do |response|
        expect(response.reload.value).to be_nil
      end
    end

    it 'clears only relevant dependent responses according to dependent value' do
      per = create(:person_escort_record)
      parent_response = create(:array_response, person_escort_record: per)
      child1_question = create(:framework_question, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child2_question = create(:framework_question, dependent_value: 'Level 2', parent: parent_response.framework_question)
      create(:string_response, framework_question: child1_question, parent: parent_response, person_escort_record: per)
      child_response = create(:string_response, framework_question: child2_question, parent: parent_response, person_escort_record: per)
      described_class.new(per, { parent_response.id => ['Level 2'] }).call

      expect(child_response.reload.value).to eq('Yes')
    end

    it 'does not clear dependent values if record invalid' do
      per = create(:person_escort_record)
      parent_response = create(:array_response, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:array_response, framework_question: child_question, parent: parent_response, person_escort_record: per)

      expect { described_class.new(per, { parent_response.id => 'Level 2' }).call }.to raise_error(FrameworkResponses::BulkUpdateError)
      expect(child_response.reload.value).to eq(['Level 1'])
    end

    it 'clears flags on dependent responses if value changed' do
      per = create(:person_escort_record)
      parent_response = create(:collection_response, :details, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, framework_flags: [create(:framework_flag)], person_escort_record: per)
      described_class.new(per, { parent_response.id => [option: 'Level 2'] }).call

      expect(child_response.reload.framework_flags).to be_empty
    end

    it 'does not clear flags on dependent responses if value not changed' do
      per = create(:person_escort_record)
      parent_response = create(:collection_response, :details, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
      flag = create(:framework_flag)
      child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, framework_flags: [flag], person_escort_record: per)
      described_class.new(per, { parent_response.id => [option: 'Level 1'] }).call

      expect(child_response.reload.framework_flags).to contain_exactly(flag)
    end

    it 'sets responded to false on dependent responses if value changed' do
      per = create(:person_escort_record)
      parent_response = create(:collection_response, :details, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, responded: true, person_escort_record: per)
      described_class.new(per, { parent_response.id => [option: 'Level 2'] }).call

      expect(child_response.reload.responded).to be(false)
    end

    it 'does not set responded to false on dependent responses if value not changed' do
      per = create(:person_escort_record)
      parent_response = create(:collection_response, :details, person_escort_record: per)
      child_question = create(:framework_question, :checkbox, followup_comment: true, dependent_value: 'Level 1', parent: parent_response.framework_question)
      child_response = create(:collection_response, :details, framework_question: child_question, parent: parent_response, responded: true, person_escort_record: per)
      described_class.new(per, { parent_response.id => [option: 'Level 1'] }).call

      expect(child_response.reload.responded).to be(true)
    end
  end

  context 'with person_escort_record status' do
    it 'does not change person escort record status answers provided invalid' do
      per = create(:person_escort_record)
      response = create(:string_response, value: nil, person_escort_record: per)

      expect { described_class.new(per, { response.id => %w[Yes] }).call }.to raise_error(FrameworkResponses::BulkUpdateError)
      expect(per.reload).to be_unstarted
    end

    it 'updates person escort record status if some answers provided' do
      per = create(:person_escort_record)
      response1 = create(:string_response, value: nil, person_escort_record: per)
      create(:string_response, value: nil, person_escort_record: per)
      described_class.new(per, { response1.id => 'Yes' }).call

      expect(per.reload).to be_in_progress
    end

    it 'does not allow updating responses if person_escort_record status is confirmed' do
      per = create(:person_escort_record, :confirmed, :with_responses)
      response = per.framework_responses.first

      expect { described_class.new(per, { response.id => 'No' }).call }.to raise_error(ActiveRecord::ReadOnlyRecord)
      expect(response.reload.value).to eq('Yes')
    end
  end
end
