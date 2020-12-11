# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EthnicitySerializer do
  subject(:serializer) { described_class.new(ethnicity) }

  let(:disabled_at) { Time.zone.local(2019, 1, 1) }
  let(:ethnicity) { create :ethnicity, disabled_at: disabled_at }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'ethnicities'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql ethnicity.id
  end

  it 'contains a key property' do
    expect(result[:data][:attributes][:key]).to eql ethnicity.key
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql ethnicity.title
  end

  it 'contains a description attribute' do
    expect(result[:data][:attributes][:description]).to eql ethnicity.description
  end

  it 'contains a nomis_code attribute' do
    expect(result[:data][:attributes][:nomis_code]).to eql ethnicity.nomis_code
  end

  it 'contains a disabled_at attribute' do
    expect(result[:data][:attributes][:disabled_at]).to eql disabled_at.iso8601
  end
end
