# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkSerializer do
  subject(:serializer) { described_class.new(framework) }

  let(:framework) { create :framework }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('frameworks')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework.id)
  end

  it 'contains a `version` attribute' do
    expect(result[:data][:attributes][:version]).to eq(framework.version)
  end

  it 'contains a `name` attribute' do
    expect(result[:data][:attributes][:name]).to eq(framework.name)
  end

  it 'contains an empty `questions` relationship if no framework questions present' do
    expect(result[:data][:relationships][:questions][:data]).to be_empty
  end

  it 'contains a `questions` relationship with framework questions' do
    question = create(:framework_question, framework:)

    expect(result[:data][:relationships][:questions][:data]).to contain_exactly(
      id: question.id,
      type: 'framework_questions',
    )
  end
end
