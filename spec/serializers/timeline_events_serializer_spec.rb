# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimelineEventsSerializer do
  subject(:serializer) { described_class.new(event) }

  let(:event) { create(:event_move_overnight_lodge) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }

  it 'contains a type property' do
    expect(result_data[:type]).to eql 'events'
  end

  it 'contains an id property' do
    expect(result_data[:id]).to eql event.id
  end

  it 'contains an occurred_at attribute' do
    expect(attributes[:occurred_at]).to eql event.occurred_at.iso8601
  end

  it 'contains an event_type attribute' do
    expect(attributes[:event_type]).to eql 'MoveOvernightLodge'
  end
end
