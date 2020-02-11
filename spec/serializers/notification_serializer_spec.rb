# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationSerializer do
  subject(:serializer) { described_class.new(notification) }

  let(:notification) { create(:notification) }

  describe 'timestamp' do
    it { expect(serializer.timestamp).to eql(notification.time_stamp) }
  end

  describe 'move?' do
    it { expect(serializer.move?).to be true }
  end

  describe 'move_url' do
    it { expect(serializer.move_url).to eql "http://localhost:4000/api/v1/moves/#{notification.topic.id}" }
  end


  describe 'json rendering' do
    let(:adapter_options) { {} }
    let(:result) do
      JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys
    end

    let(:expected_result) {
      {
          "data": {
              "id": notification.id,
              "type": 'notifications',
              "attributes": {
                  "event_type": 'move_created',
                  "timestamp": notification.time_stamp.as_json,
              },
              "relationships": {
                  "move": {
                      "data": {
                          "id": notification.topic.id,
                          "type": 'moves',
                      },
                      "links": {
                          "self": "http://localhost:4000/api/v1/moves/#{notification.topic.id}",
                      },
                  },
              },
          },
      }
    }

    it 'contains a type property' do
      expect(result[:data][:type]).to eql 'notifications'
    end

    it 'contains an id property' do
      expect(result[:data][:id]).to eql notification.id
    end

    it 'contains a event_type attribute' do
      expect(result[:data][:attributes][:event_type]).to eql 'move_created'
    end

    it 'contains a timestamp attribute' do
      expect(result[:data][:attributes][:timestamp]).to eql notification.time_stamp.as_json
    end

    it 'contains a move relationship data' do
      expect(result[:data][:relationships][:move][:data]).to eql(id: notification.topic.id, type: 'moves')
    end

    it 'contains a move relationship links' do
      expect(result[:data][:relationships][:move][:links]).to eql(self: "http://localhost:4000/api/v1/moves/#{notification.topic.id}")
    end

    it 'renders the correct json' do
      expect(result).to eql(expected_result)
    end
  end
end
