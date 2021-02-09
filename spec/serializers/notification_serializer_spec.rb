# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationSerializer do
  subject(:serializer) { described_class.new(notification, adapter_options) }

  let(:adapter_options) { {} }
  let(:notification) { create(:notification) }

  describe 'json rendering' do
    let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

    let(:expected_result) do
      {
        "data": {
          "id": notification.id,
          "type": 'notifications',
          "attributes": {
            "event_type": 'move_created',
            "timestamp": notification.created_at.iso8601,
          },
        },
      }
    end

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
      expect(result[:data][:attributes][:timestamp]).to eql notification.created_at.as_json
    end

    context 'when topic is a Move' do
      it 'contains move relationship data' do
        expect(result[:data][:relationships][:move][:data]).to eql(id: notification.topic.id, type: 'moves')
      end

      it 'contains move relationship links' do
        expect(result[:data][:relationships][:move][:links]).to eql(self: "http://localhost:4000/api/v1/moves/#{notification.topic.id}")
      end
    end

    context 'when topic is a PersonEscortRecord' do
      let(:per) { create(:person_escort_record) }
      let(:notification) { create(:notification, topic: per) }

      it 'contains person_escort_record relationship data' do
        expect(result[:data][:relationships][:person_escort_record][:data]).to eql(id: per.id, type: 'person_escort_records')
      end

      it 'contains person_escort_record relationship links' do
        expect(result[:data][:relationships][:person_escort_record][:links]).to eql(self: "http://localhost:4000/api/v1/person_escort_records/#{per.id}")
      end
    end

    context 'when topic is not a Move or PersonEscortRecord' do
      let(:allocation) { create(:allocation) }
      let(:notification) { create(:notification, topic: allocation) }

      it 'does not contain relationship data' do
        expect(result[:data][:relationships]).to be_empty
      end
    end

    it 'renders the correct json' do
      expect(result).to include_json(expected_result)
    end
  end
end
