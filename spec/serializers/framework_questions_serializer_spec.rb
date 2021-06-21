# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkQuestionsSerializer do
  subject(:serializer) { described_class.new(framework_question, adapter_options) }

  let(:flag) { create :framework_flag }
  let(:dependent_question) { create :framework_question }
  let(:framework_question) { create :framework_question, dependents: [dependent_question], framework_flags: [flag] }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:adapter_options) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_questions')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework_question.id)
  end

  it 'contains a `section` attribute' do
    expect(result[:data][:attributes][:section]).to eq(framework_question.section)
  end

  it 'contains a `key` attribute' do
    expect(result[:data][:attributes][:key]).to eq(framework_question.key)
  end

  it 'contains a `question_type` attribute' do
    expect(result[:data][:attributes][:question_type]).to eq(framework_question.question_type)
  end

  it 'contains a `options` attribute' do
    expect(result[:data][:attributes][:options]).to eq(framework_question.options)
  end

  it 'contains a `response_type` attribute' do
    expect(result[:data][:attributes][:response_type]).to eq(framework_question.response_type)
  end

  context 'with descendants' do
    let(:adapter_options) { { params: { included: %i[descendants] } } }

    it 'contains a `descendants` relationship' do
      expect(result[:data][:relationships][:descendants][:data]).to contain_exactly(
        id: dependent_question.id,
        type: 'framework_questions',
      )
    end
  end

  context 'with flags' do
    let(:adapter_options) { { params: { included: %i[flags] } } }

    it 'contains a `flags` relationship' do
      expect(result[:data][:relationships][:flags][:data]).to contain_exactly(
        id: flag.id,
        type: 'framework_flags',
      )
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  context 'with include options' do
    let(:adapter_options) do
      {
        include: %w[descendants flags],
        params: { included: %i[descendants flags] },
      }
    end

    let(:expected_json) do
      [
        {
          id: dependent_question.id,
          type: 'framework_questions',
          attributes: { question_type: dependent_question.question_type },
        },
        {
          id: flag.id,
          type: 'framework_flags',
          attributes: { title: flag.title },
        },
      ]
    end

    it 'contains included descendants and flags' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
