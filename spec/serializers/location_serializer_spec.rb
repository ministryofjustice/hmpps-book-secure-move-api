# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationSerializer do
  subject(:serializer) { described_class.new(location) }

  let(:disabled_at) { Time.new(2019, 1, 1) }
  let(:location) { create :location, disabled_at: disabled_at }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'locations'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql location.id
  end

  it 'contains a location_type attribute' do
    expect(result[:data][:attributes][:location_type]).to eql 'prison'
  end

  it 'contains a key attribute' do
    expect(result[:data][:attributes][:key]).to eql 'hmp_pentonville'
  end

  it 'contains a title attribute' do
    expect(result[:data][:attributes][:title]).to eql 'HMP Pentonville'
  end

  it 'contains a nomis_agency_id attribute' do
    expect(result[:data][:attributes][:nomis_agency_id]).to eql 'PEI'
  end

  it 'contains a disabled_at attribute' do
    expect(Time.parse(result[:data][:attributes][:disabled_at])).to eql disabled_at
  end
end
