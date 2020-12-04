# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AllocationComplexCaseSerializer do
  subject(:serializer) { described_class.new(allocation_complex_case) }

  let(:allocation_complex_case) { create :allocation_complex_case }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'allocation_complex_cases'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql allocation_complex_case.id
  end

  it 'contains a key attribute' do
    expect(result[:data][:attributes][:key]).to eql allocation_complex_case.key
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql allocation_complex_case.title
  end
end
