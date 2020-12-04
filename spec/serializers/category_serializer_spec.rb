# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategorySerializer do
  subject(:serializer) { described_class.new(category) }

  let(:category) { create(:category, :not_supported) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }

  it 'contains a type property' do
    expect(result_data[:type]).to eql 'categories'
  end

  it 'contains an id property' do
    expect(result_data[:id]).to eql category.id
  end

  it 'contains a key attribute' do
    expect(attributes[:key]).to eql category.key
  end

  it 'contains a title attribute' do
    expect(attributes[:title]).to eql category.title
  end

  it 'contains a move_supported attribute' do
    expect(attributes[:move_supported]).to eql category.move_supported
  end

  it 'contains a created_at attribute' do
    expect(attributes[:created_at]).to eql category.created_at.iso8601
  end

  it 'contains an updated_at attribute' do
    expect(attributes[:updated_at]).to eql category.updated_at.iso8601
  end
end
