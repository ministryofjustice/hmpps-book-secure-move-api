# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkQuestionSerializer do
  subject(:serializer) { described_class.new(framework_question) }

  let(:framework_question) { create :framework_question }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer).serializable_hash }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_questions')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework_question.id)
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

  it 'contains a `framework` relationship' do
    expect(result[:data][:relationships][:framework][:data]).to eq(
      id: framework_question.framework.id,
      type: 'frameworks',
    )
  end
end
