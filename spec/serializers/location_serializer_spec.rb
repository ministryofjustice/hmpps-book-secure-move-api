# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationSerializer do
  subject(:serializer) { described_class.new(location) }

  let(:location) { create :location }
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

  it 'contains a label attribute' do
    expect(result[:data][:attributes][:label]).to eql 'HMP Pentonville'
  end
end
