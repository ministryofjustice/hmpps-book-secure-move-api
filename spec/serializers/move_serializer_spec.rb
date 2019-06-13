# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveSerializer do
  subject(:serializer) { described_class.new(move) }

  let(:move) { create :move }
  let(:adapter_options) { {} }
  let(:result) do
    JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys
  end

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'moves'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql move.id
  end

  it 'contains a status attribute' do
    expect(result[:data][:attributes][:status]).to eql move.status
  end

  it 'contains a date attribute' do
    expect(result[:data][:attributes][:date]).to eql move.date.iso8601
  end

  it 'contains a time attribute' do
    expect(result[:data][:attributes][:time_due]).to eql move.time_due.iso8601
  end

  it 'contains an updated_at attribute' do
    expect(result[:data][:attributes][:updated_at]).to eql move.updated_at.iso8601
  end

  describe 'person' do
    let(:adapter_options) { { include: { person: %I[first_names last_name] } } }
    let(:expected_json) do
      [
        {
          id: move.person_id,
          type: 'people',
          attributes: { first_names: 'Bob', last_name: 'Roberts', date_of_birth: '1980-10-20' }
        }
      ]
    end

    it 'contains an included person' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end

  describe 'locations' do
    let(:adapter_options) do
      {
        include: {
          from_location: %I[location_type description],
          to_location: %I[location_type description]
        }
      }
    end
    let(:expected_json) do
      [
        {
          id: move.from_location_id,
          type: 'locations',
          attributes: { location_type: 'prison', description: 'HMP Pentonville' }
        },
        {
          id: move.to_location_id,
          type: 'locations',
          attributes: { location_type: 'court', description: 'Guildford Crown Court' }
        }
      ]
    end

    it 'contains an included from and to location' do
      expect(result[:included]).to(include_json(expected_json))
    end
  end
end
