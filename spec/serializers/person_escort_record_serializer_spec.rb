# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecordSerializer do
  subject(:serializer) { described_class.new(person_escort_record, include: includes) }

  let(:move) { create(:move) }
  let(:person_escort_record) { create(:person_escort_record, move: move, profile: move.profile) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('person_escort_records')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(person_escort_record.id)
  end

  it 'contains a `status` attribute' do
    expect(result[:data][:attributes][:status]).to eq('not_started')
  end

  it 'contains a `version` attribute' do
    expect(result[:data][:attributes][:version]).to eq(person_escort_record.framework.version)
  end

  it 'contains a `editable` attribute' do
    expect(result[:data][:attributes][:editable]).to eq(person_escort_record.editable)
  end

  it 'contains a `confirmed_at` attribute' do
    expect(result[:data][:attributes][:confirmed_at]).to eq(person_escort_record.confirmed_at)
  end

  it 'contains a `created_at` attribute' do
    expect(result[:data][:attributes][:created_at]).to eq(person_escort_record.created_at.iso8601)
  end

  it 'contains a `nomis_sync_status` attribute' do
    expect(result[:data][:attributes][:nomis_sync_status]).to eq(person_escort_record.nomis_sync_status)
  end

  it 'contains a `profile` relationship' do
    expect(result[:data][:relationships][:profile][:data]).to eq(
      id: person_escort_record.profile.id,
      type: 'profiles',
    )
  end

  it 'contains a `move` relationship' do
    expect(result[:data][:relationships][:move][:data]).to eq(
      id: person_escort_record.move.id,
      type: 'moves',
    )
  end

  it 'contains a `framework` relationship' do
    expect(result[:data][:relationships][:framework][:data]).to eq(
      id: person_escort_record.framework.id,
      type: 'frameworks',
    )
  end

  it 'contains an empty `responses` relationship if no responses present' do
    expect(result[:data][:relationships][:responses][:data]).to be_empty
  end

  it 'contains a`responses` relationship with framework responses' do
    response = create(:string_response, assessmentable: person_escort_record)

    expect(result[:data][:relationships][:responses][:data]).to contain_exactly(
      id: response.id,
      type: 'framework_responses',
    )
  end

  it 'contains an empty `flags` relationship if no flags present' do
    expect(result[:data][:relationships][:flags][:data]).to be_empty
  end

  it 'contains a`flags` relationship with framework response flags' do
    flag = create(:framework_flag)
    create(:string_response, assessmentable: person_escort_record, framework_flags: [flag])

    expect(result[:data][:relationships][:flags][:data]).to contain_exactly(
      id: flag.id,
      type: 'framework_flags',
    )
  end

  it 'contains a nil `prefill_source` relationship if no prefill_source present' do
    expect(result[:data][:relationships][:prefill_source][:data]).to be_nil
  end

  context 'with a prefill source' do
    let(:person_escort_record) { create(:person_escort_record, :prefilled, move: move, profile: move.profile) }

    it 'contains a`prefill_source` relationship ' do
      expect(result[:data][:relationships][:prefill_source][:data]).to eq(
        id: person_escort_record.prefill_source.id,
        type: 'person_escort_records',
      )
    end
  end

  describe 'meta' do
    it 'includes section progress' do
      question = create(:framework_question, framework: person_escort_record.framework, section: 'risk-information')
      create(:string_response, value: nil, framework_question: question, assessmentable: person_escort_record)

      expect(result[:data][:meta][:section_progress]).to contain_exactly(
        key: 'risk-information',
        status: 'not_started',
      )
    end

    context 'with no questions' do
      it 'does not include includes section progress' do
        expect(result[:data][:meta][:section_progress]).to be_empty
      end
    end
  end

  context 'with include options' do
    let(:includes) { ['responses', 'prefill_source', 'responses.question', 'responses.nomis_mappings'] }
    let(:framework_nomis_mapping) { create(:framework_nomis_mapping) }
    let(:person_escort_record) do
      person_escort_record = create(:person_escort_record, :prefilled)
      create(:object_response, framework_nomis_mappings: [framework_nomis_mapping], assessmentable: person_escort_record)
      person_escort_record
    end
    let(:framework_response) { person_escort_record.framework_responses.first }

    let(:expected_json) do
      UnorderedArray(
        {
          id: framework_response.id,
          type: 'framework_responses',
          attributes: { value: framework_response.value },
        },
        {
          id: framework_response.framework_question.id,
          type: 'framework_questions',
          attributes: { key: framework_response.framework_question.key },
        },
        {
          id: framework_nomis_mapping.id,
          type: 'framework_nomis_mappings',
          attributes: { code: framework_nomis_mapping.code },
        },
        {
          id: person_escort_record.prefill_source.id,
          type: 'person_escort_records',
          attributes: { created_at: person_escort_record.prefill_source.created_at.iso8601 },
        },
      )
    end

    it 'contains an included responses and question' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
