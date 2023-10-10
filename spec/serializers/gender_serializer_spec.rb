# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenderSerializer do
  subject(:serializer) { described_class.new(gender) }

  let(:disabled_at) { Time.zone.local(2019, 1, 1) }
  let(:gender) { create :gender, disabled_at: }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'genders'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql gender.id
  end

  it 'contains a `key` attribute' do
    expect(result[:data][:attributes][:key]).to eql 'female'
  end

  it 'contains a `title` attribute' do
    expect(result[:data][:attributes][:title]).to eql 'Female'
  end

  it 'contains a `nomis_code` attribute' do
    expect(result[:data][:attributes][:nomis_code]).to eql 'F'
  end

  it 'contains a disabled_at attribute' do
    expect(result[:data][:attributes][:disabled_at]).to eql disabled_at.iso8601
  end
end
