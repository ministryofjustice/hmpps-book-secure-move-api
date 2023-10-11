# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrisonTransferReasonSerializer do
  subject(:serializer) { described_class.new(reason) }

  let(:disabled_at) { Time.zone.local(2019, 1, 1) }
  let(:reason) { create :prison_transfer_reason, disabled_at: }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'prison_transfer_reasons'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql reason.id
  end

  it 'contains a `key` attribute' do
    expect(result[:data][:attributes][:key]).to eql reason.key
  end

  it 'contains a `title` attribute' do
    expect(result[:data][:attributes][:title]).to eql reason.title
  end

  it 'contains a `disabled_at` attribute' do
    expect(result[:data][:attributes][:disabled_at]).to eql disabled_at.iso8601
  end
end
