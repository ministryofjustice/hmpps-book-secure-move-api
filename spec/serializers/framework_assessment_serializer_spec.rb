# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkAssessmentSerializer do
  subject(:serializer) { described_class.new(assessment, includes) }

  let(:move) { create(:move) }
  let(:assessment) { create(:person_escort_record, move: move, profile: move.profile) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:includes) { {} }

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(assessment.id)
  end

  it 'contains a `status` attribute' do
    expect(result[:data][:attributes][:status]).to eq('not_started')
  end

  it 'contains a `version` attribute' do
    expect(result[:data][:attributes][:version]).to eq(assessment.framework.version)
  end

  it 'contains a `editable` attribute' do
    expect(result[:data][:attributes][:editable]).to eq(assessment.editable?)
  end

  it 'contains a `confirmed_at` attribute' do
    expect(result[:data][:attributes][:confirmed_at]).to eq(assessment.confirmed_at)
  end

  it 'contains a `created_at` attribute' do
    expect(result[:data][:attributes][:created_at]).to eq(assessment.created_at.iso8601)
  end

  it 'contains a `nomis_sync_status` attribute' do
    expect(result[:data][:attributes][:nomis_sync_status]).to eq(assessment.nomis_sync_status)
  end

  it 'contains a `framework` relationship' do
    expect(result[:data][:relationships][:framework][:data]).to eq(
      id: assessment.framework.id,
      type: 'frameworks',
    )
  end

  context 'with responses' do
    let(:includes) { { params: { included: %i[responses] } } }

    it 'contains an empty `responses` relationship if no responses present' do
      expect(result[:data][:relationships][:responses][:data]).to be_empty
    end

    it 'contains a`responses` relationship with framework responses' do
      response = create(:string_response, assessmentable: assessment)

      expect(result[:data][:relationships][:responses][:data]).to contain_exactly(
        id: response.id,
        type: 'framework_responses',
      )
    end
  end

  context 'with flags' do
    let(:includes) { { params: { included: %i[flags] } } }

    it 'contains an empty `flags` relationship if no flags present' do
      expect(result[:data][:relationships][:flags][:data]).to be_empty
    end

    it 'contains a `flags` relationship with framework response flags' do
      flag = create(:framework_flag)
      create(:string_response, assessmentable: assessment, framework_flags: [flag])

      expect(result[:data][:relationships][:flags][:data]).to contain_exactly(
        id: flag.id,
        type: 'framework_flags',
      )
    end
  end

  describe 'meta' do
    it 'includes section progress' do
      question = create(:framework_question, framework: assessment.framework, section: 'risk-information')
      create(:string_response, value: nil, framework_question: question, assessmentable: assessment)
      assessment.update_status_and_progress!

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
    let(:includes) do
      {
        include: %w[responses responses.question responses.nomis_mappings],
        params: { included: %i[responses question nomis_mappings] },
      }
    end
    let(:framework_nomis_mapping) { create(:framework_nomis_mapping) }
    let(:assessment) do
      assessment = create(:person_escort_record)
      create(:object_response, framework_nomis_mappings: [framework_nomis_mapping], assessmentable: assessment)
      assessment
    end
    let(:framework_response) { assessment.framework_responses.first }

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
      )
    end

    it 'contains an included responses and question' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
