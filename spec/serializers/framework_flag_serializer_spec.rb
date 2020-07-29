# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkFlagSerializer do
  subject(:serializer) { described_class.new(framework_flag) }

  let(:framework_flag) { create(:framework_flag) }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer, include: includes).serializable_hash }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_flags')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework_flag.id)
  end

  it 'contains a `title` attribute' do
    expect(result[:data][:attributes][:title]).to eq(framework_flag.title)
  end

  it 'contains a `flag_type` attribute' do
    expect(result[:data][:attributes][:flag_type]).to eq(framework_flag.flag_type)
  end

  it 'contains a `question_value` attribute' do
    expect(result[:data][:attributes][:question_value]).to eq(framework_flag.question_value)
  end

  it 'contains a `question` relationship' do
    expect(result[:data][:relationships][:question][:data]).to eq(
      id: framework_flag.framework_question.id,
      type: 'framework_questions',
    )
  end

  context 'with include options' do
    let(:includes) do
      {
        question: :key,
      }
    end

    let(:expected_json) do
      [
        {
          id: framework_flag.framework_question.id,
          type: 'framework_questions',
          attributes: { key: framework_flag.framework_question.key },
        },
      ]
    end

    it 'contains an included question' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
