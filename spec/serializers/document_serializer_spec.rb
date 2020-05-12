# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentSerializer do
  subject(:serializer) { described_class.new(document) }

  let(:document) { create :document }
  let(:result) { ActiveModelSerializers::Adapter.create(serializer).serializable_hash }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'documents'
  end

  it 'contains and `id` property' do
    expect(result[:data][:id]).to eql document.id
  end

  it 'contains a `filename` attribute' do
    expect(result[:data][:attributes][:filename].to_s).to eql 'file-sample_100kB.doc'
  end

  it 'contains a `filesize` attribute' do
    expect(result[:data][:attributes][:filesize]).to be 100352
  end

  it 'contains a `content_type` attribute' do
    expect(result[:data][:attributes][:content_type]).to eql 'application/msword'
  end
end
