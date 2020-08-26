# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericEventSerializer do
  subject(:serializer) { described_class.new(event) }

  let(:event) { create :event_move_cancel }

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
            occurred_at: event.occurred_at.iso8601,
            recorded_at: event.recorded_at.iso8601,
            notes: 'Flibble',
            event_type: 'MoveCancel',
            details: {
              cancellation_reason: 'made_in_error',
              cancellation_reason_comment: 'It was a mistake',
            },
          },
          relationships: {
            eventable: { data: { type: 'moves', id: move.id } },
          },
        },
      }
    end
    let(:move) { event.eventable }

    it { expect(result).to include_json(expected_json) }
    it { expect(result[:included]).to be_nil }
  end
end
