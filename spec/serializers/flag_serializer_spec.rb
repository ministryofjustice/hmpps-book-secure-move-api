# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlagSerializer do
  subject(:serializer) { described_class.new(flag) }

  let(:flag) { create(:flag) }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer, include: includes).serializable_hash }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_flags')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(flag.id)
  end

  it 'contains a `name` attribute' do
    expect(result[:data][:attributes][:name]).to eq(flag.name)
  end

  it 'contains a `flag_type` attribute' do
    expect(result[:data][:attributes][:flag_type]).to eq(flag.flag_type)
  end

  it 'contains a `question_value` attribute' do
    expect(result[:data][:attributes][:question_value]).to eq(flag.question_value)
  end

  it 'contains a `question` relationship' do
    expect(result[:data][:relationships][:question][:data]).to eq(
      id: flag.framework_question.id,
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
          id: flag.framework_question.id,
          type: 'framework_questions',
          attributes: { key: flag.framework_question.key },
        },
      ]
    end

    it 'contains an included question' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
