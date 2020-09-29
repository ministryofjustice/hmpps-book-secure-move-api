# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEvents::EventSpecificRelationshipsMapper do
  subject(:mapper) { described_class.new(ActionController::Parameters.new(event_relationships)) }

  context 'when only the eventable is passed' do
    let(:event_relationships) do
      { 'eventable' => { 'data' => { 'id' => 'wibble', 'type' => 'moves' } } }
    end

    it 'returns an empty Hash' do
      expect(mapper.call).to eq({})
    end
  end

  context 'when an empty Hash is passed' do
    let(:event_relationships) { {} }

    it 'returns an empty Hash' do
      expect(mapper.call).to eq({})
    end
  end

  context 'when only a from_location is passed' do
    let(:event_relationships) do
      {
        'from_location' => { 'data' => { 'id' => 'bar', 'type' => 'locations' } },
      }
    end

    it 'returns a properly mapped from_location' do
      expect(mapper.call).to eq('from_location_id' => 'bar')
    end
  end

  context 'when both a from_location and eventble are passed' do
    let(:event_relationships) do
      {
        'eventable' => { 'data' => { 'id' => 'foo', 'type' => 'moves' } },
        'from_location' => { 'data' => { 'id' => 'bar', 'type' => 'locations' } },
      }
    end

    it 'returns a properly mapped from_location' do
      expect(mapper.call).to eq('from_location_id' => 'bar')
    end
  end
end
