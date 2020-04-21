# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComplexCaseSerializer do
  subject(:serializer) { described_class.new(complex_case) }

  let(:complex_case) { create :complex_case }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'complex_cases'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql complex_case.id
  end

  it 'contains a key property' do
    expect(result[:data][:attributes][:key]).to eql complex_case.key
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql complex_case.title
  end
end
