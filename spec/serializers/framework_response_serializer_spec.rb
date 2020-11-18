# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkResponseSerializer do
  subject(:serializer) { described_class.new(framework_response, include: includes) }

  let(:framework_response) { create(:string_response) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
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

  it 'contains a `prefilled` attribute' do
    expect(result[:data][:attributes][:prefilled]).to eq(framework_response.prefilled)
  end

  # TODO: remove once transition to assessment is complete
  it 'contains a `person_escort_record` relationship' do
    expect(result[:data][:relationships][:person_escort_record][:data]).to eq(
      id: framework_response.person_escort_record.id,
      type: 'person_escort_records',
    )
  end

  it 'contains a `assessment` relationship' do
    expect(result[:data][:relationships][:assessment][:data]).to eq(
      id: framework_response.assessmentable.id,
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

  it 'contains an empty `nomis_mappings` relationship if no nomis_mappings present' do
    expect(result[:data][:relationships][:nomis_mappings][:data]).to be_empty
  end

  it 'contains a `nomis_mappings` relationship when nomis_mappings present' do
    framework_nomis_mapping = create(:framework_nomis_mapping)
    framework_response.update(framework_nomis_mappings: [framework_nomis_mapping])

    expect(result[:data][:relationships][:nomis_mappings][:data]).to contain_exactly(
      id: framework_nomis_mapping.id,
      type: 'framework_nomis_mappings',
    )
  end

  context 'with include options' do
    let(:includes) do
      %i[person_escort_record assessment question]
    end
    let(:framework_response) do
      create(:string_response, assessmentable: create(:person_escort_record))
    end

    let(:expected_json) do
      [
        {
          id: framework_response.assessmentable.id,
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
