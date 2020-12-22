# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::JourneysSerializer do
  subject(:serializer) { described_class.new(journey, adapter_options) }

  let(:journey) { create :journey, client_timestamp: '2020-05-04T08:00:00Z' }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:adapter_options) { {} }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'journeys'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql journey.id
  end

  it 'contains a `billable` attribute' do
    expect(result[:data][:attributes][:billable]).to be false
  end

  it 'contains a `state` attribute' do
    expect(result[:data][:attributes][:state]).to eql 'proposed'
  end

  it 'contains a `timestamp` attribute' do
    expect(result[:data][:attributes][:timestamp]).to eql '2020-05-04T09:00:00+01:00'
  end

  it 'contains vehicle attributes' do
    expect(result[:data][:attributes][:vehicle]).to eql(id: '12345678ABC', registration: 'AB12 CDE')
  end
end
