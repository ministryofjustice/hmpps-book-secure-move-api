# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifierTypeSerializer do
  subject(:serializer) { described_class.new(identifier_type) }

  let(:disabled_at) { Time.new(2019, 1, 1) }
  let(:identifier_type) { create :identifier_type, disabled_at: disabled_at }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'identifier_types'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql identifier_type.id
  end

  it 'contains a key attribute' do
    expect(result[:data][:attributes][:key]).to eql identifier_type.key
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql 'PNC ID'
  end

  it 'contains a disabled_at attribute' do
    expect(result[:data][:attributes][:disabled_at]).to eql disabled_at.iso8601
  end
end
