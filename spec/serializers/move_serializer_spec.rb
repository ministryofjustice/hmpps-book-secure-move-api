# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveSerializer do
  subject(:serializer) { described_class.new(move) }

  let(:move) { create :move }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }

  it 'contains a type property' do
    expect(result[:data][:type]).to eql 'moves'
  end

  it 'contains an id property' do
    expect(result[:data][:id]).to eql move.id
  end

  it 'contains a date attribute' do
    expect(result[:data][:attributes][:date]).to eql move.date.iso8601
  end

  it 'contains a time attribute' do
    expect(result[:data][:attributes][:time_due]).to eql move.time_due.iso8601
  end

  it 'contains a type attribute' do
    expect(result[:data][:attributes][:type]).to eql move.move_type
  end

  it 'contains an updated_at attribute' do
    expect(result[:data][:attributes][:updated_at]).to eql move.updated_at.iso8601
  end

  describe 'person' do
    it 'contains an embedded person' do
      expect(result[:data][:relationships][:person]).to include_json(data: { id: move.person_id, type: 'people' })
    end
  end
end
