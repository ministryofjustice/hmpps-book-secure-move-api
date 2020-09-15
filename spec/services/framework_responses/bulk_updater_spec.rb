# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponses::BulkUpdater do
  it 'marks values as responded' do
    per = create(:person_escort_record)
    response1 = create(:string_response, person_escort_record: per, value: nil)
    response2 = create(:string_response, person_escort_record: per, value: nil)
    described_class.new(per, { response1.id => 'Yes', response2.id => 'No' }).call

    expect(response1.reload).to be_responded
    expect(response2.reload).to be_responded
  end

  it 'updates response values' do
    per = create(:person_escort_record)
    response1 = create(:string_response, person_escort_record: per, value: nil)
    response2 = create(:string_response, person_escort_record: per, value: nil)
    described_class.new(per, { response1.id => 'Yes', response2.id => 'No' }).call

    expect(response1.reload.value).to eq('Yes')
    expect(response2.reload.value).to eq('No')
  end

  it 'attaches flags if answer supplied matches flag for string' do
    per = create(:person_escort_record)
    flag1 = create(:framework_flag)
    flag2 = create(:framework_flag)
    response1 = create(:string_response, value: nil, framework_question: flag1.framework_question, person_escort_record: per)
    response2 = create(:string_response, value: nil, framework_question: flag2.framework_question, person_escort_record: per)
    described_class.new(per, { response1.id => 'Yes', response2.id => 'No' }).call

    expect(response1.reload.framework_flags).to contain_exactly(flag1)
    expect(response2.reload.framework_flags).to be_empty
  end

  it 'detaches flag if answer changed' do
    per = create(:person_escort_record)
    framework_question = create(:framework_question)
    flag1 = create(:framework_flag, framework_question: framework_question)
    flag2 = create(:framework_flag, framework_question: framework_question)
    response1 = create(:string_response, framework_question: framework_question, framework_flags: [flag1, flag2], person_escort_record: per)
    response2 = create(:string_response, framework_question: framework_question, framework_flags: [flag1, flag2], person_escort_record: per)
    described_class.new(per, { response1.id => 'No', response2.id => 'Yes' }).call

    expect(response1.reload.framework_flags).to be_empty
    expect(response2.reload.framework_flags).to contain_exactly(flag1, flag2)
  end

  context 'when dependent responses' do
    it 'clears dependent responses if value changed' do
      per = create(:person_escort_record)
      parent1_response = create(:string_response, person_escort_record: per)
      parent2_response = create(:string_response, person_escort_record: per)
      child1_question = create(:framework_question, dependent_value: 'Yes', parent: parent1_response.framework_question)
      child2_question = create(:framework_question, dependent_value: 'Yes', parent: parent2_response.framework_question)
      child_response1 = create(:string_response, framework_question: child1_question, parent: parent1_response, person_escort_record: per)
      child_response2 = create(:string_response, framework_question: child2_question, parent: parent2_response, person_escort_record: per)
      described_class.new(per, { parent1_response.id => 'No', parent2_response.id => 'No' }).call

      [child_response1, child_response2].each do |response|
        expect(response.reload.value).to be_nil
      end
    end
  end

  context 'with validation error' do
    it 'raises BulkUpdateErrors' do
      per = create(:person_escort_record)
      response1 = create(:string_response, person_escort_record: per, value: nil)
      response2 = create(:string_response, person_escort_record: per, value: nil)

      expect { described_class.new(per, { response1.id => 'Foo', response2.id => 'No' }).call }.to raise_error(FrameworkResponses::BulkUpdateError)
    end

    it 'does not update responses' do
      per = create(:person_escort_record)
      response1 = create(:string_response, person_escort_record: per, value: nil)
      response2 = create(:string_response, person_escort_record: per, value: nil)
      described_class.new(per, { response1.id => 'Foo', response2.id => 'No' }).call

    rescue FrameworkResponses::BulkUpdateError
      expect(response1.reload.value).to be_nil
      expect(response2.reload.value).to be_nil
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
