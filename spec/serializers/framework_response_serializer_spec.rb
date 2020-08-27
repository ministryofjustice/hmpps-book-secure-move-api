# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponseSerializer do
  subject(:serializer) { described_class.new(framework_response) }

  let(:framework_response) { create(:string_response) }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer, include: includes).serializable_hash }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_responses')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework_response.id)
  end

  it 'contains a `value` attribute' do
    expect(result[:data][:attributes][:value]).to eq(framework_response.value)
  end

  it 'contains a `responded` attribute' do
    expect(result[:data][:attributes][:responded]).to eq(framework_response.responded)
  end

  it 'contains a `value_type` attribute' do
    expect(result[:data][:attributes][:value_type]).to eq(framework_response.framework_question.response_type)
  end

  it 'contains a `person_escort_record` relationship' do
    expect(result[:data][:relationships][:person_escort_record][:data]).to eq(
      id: framework_response.person_escort_record.id,
      type: 'person_escort_records',
    )
  end

  it 'contains a `question` relationship' do
    expect(result[:data][:relationships][:question][:data]).to eq(
      id: framework_response.framework_question.id,
      type: 'framework_questions',
    )
  end

  it 'contains an empty `flags` relationship if no flags present' do
    expect(result[:data][:relationships][:flags][:data]).to be_empty
  end

  it 'contains a`flags` relationship when flags present' do
    flag = create(:framework_flag)
    framework_response.update(framework_flags: [flag])

    expect(result[:data][:relationships][:flags][:data]).to contain_exactly(
      id: flag.id,
      type: 'framework_flags',
    )
  end

  context 'with include options' do
    let(:includes) do
      {
        person_escort_record: :status,
        question: :key,
      }
    end
    let(:framework_response) do
      create(:string_response, person_escort_record: create(:person_escort_record))
    end

    let(:expected_json) do
      [
        {
          id: framework_response.person_escort_record.id,
          type: 'person_escort_records',
          attributes: { status: 'not_started' },
        },
        {
          id: framework_response.framework_question.id,
          type: 'framework_questions',
          attributes: { key: framework_response.framework_question.key },
        },
      ]
    end

    it 'contains an included question and person_escort_record' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
