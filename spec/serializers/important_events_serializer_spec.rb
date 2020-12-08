# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportantEventsSerializer do
  subject(:serializer) { described_class.new(event) }

  let(:event) { create(:event_person_move_assault) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }

  it 'contains a type property' do
    expect(result_data[:type]).to eql 'events'
  end

  it 'contains an id property' do
    expect(result_data[:id]).to eql event.id
  end

  it 'contains an event_type attribute' do
    expect(attributes[:event_type]).to eql 'PersonMoveAssault'
  end

  it 'contains a classification attribute' do
    expect(attributes[:classification]).to eql 'incident'
  end
end
