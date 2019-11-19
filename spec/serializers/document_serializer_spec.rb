# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentSerializer do
  subject(:serializer) { described_class.new(document) }

  let(:document) { create :document }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'documents'
  end

  it 'contains and `id` property' do
    expect(result[:data][:id]).to eql document.id
  end

  it 'contains a `description` attribute' do
    expect(result[:data][:attributes][:description]).to eql 'some details about the document'
  end

  it 'contains a `document_type` attribute' do
    expect(result[:data][:attributes][:document_type]).to eql 'ID'
  end

  it 'contains a `file` attribute' do
    expect(result[:data][:attributes][:file]).to match(/file-sample_100kB/)
  end
end
