# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSerializer do
  subject(:serializer) { described_class.new(event) }

  let(:event) { create :event }

  let(:result) do
    JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys
  end

  context 'with no options' do
    let(:adapter_options) { {} }
    let(:expected_json) do
      {
        data: {
          id: event.id,
          type: 'events',
          attributes: {
            client_timestamp: event.client_timestamp.iso8601,
            notes: 'Something or other',
            event_type: 'MoveCancelV2',
            details: {
              cancellation_reason: 'made_in_error',
              cancellation_reason_comment: 'Something or other',
            },
          },
          relationships: {
            eventable: { data: { type: 'moves', id: move.id } },
          },
        },
      }
    end
    let(:move) { create(:move) }
    let(:event) do
      create(
        :event,
        eventable: move,
        event_name: 'n/a',
        notes: 'Something or other',
        type: 'Event::MoveCancelV2',
        details: {
          cancellation_reason: 'made_in_error',
          cancellation_reason_comment: 'Something or other',
        },
      )
    end

    it { expect(result).to include_json(expected_json) }
    it { expect(result[:included]).to be_nil }
  end
end
