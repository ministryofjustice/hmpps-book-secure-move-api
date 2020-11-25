# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkFlagsSerializer do
  subject(:serializer) { described_class.new(framework_flag) }

  let(:framework_flag) { create(:framework_flag) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

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
end
