# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtraditionFlightSerializer do
  subject(:serializer) { described_class.new(extradition_flight, adapter_options) }

  let(:extradition_flight) { create :extradition_flight }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:adapter_options) { {} }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'extradition_flight'
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eql extradition_flight.id
  end

  it 'contains a `flight_number` property' do
    expect(result[:data][:attributes][:flight_number]).to eql 'BA0001'
  end

  it 'contains an `flight_time` property' do
    expect(result[:data][:attributes][:flight_time]).to eql '2024-01-01T12:00:00'
  end

  it 'contains a `move` relationship' do
    expect(result[:data][:relationships][:move]).to eql(data: { id: extradition_flight.move.id, type: 'moves' })
  end

  describe 'included relationships' do
    let(:adapter_options) do
      {
        include: %w[move],
      }
    end

    let(:expected_json) do
      [
        {
          id: extradition_flight.move_id,
          type: 'moves',
          attributes: { reference: extradition_flight.move.reference },
        },
      ]
    end

    it 'contains an included move' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end
end
