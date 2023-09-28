# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::MoveSerializer do
  subject(:serializer) { described_class.new(move, adapter_options) }

  let(:move) { create :move }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  context 'with no options' do
    let(:adapter_options) { {} }
    let(:expected_json) do
      {
        data: {
          id: move.id,
          type: 'moves',
          attributes: {
            additional_information: 'some more info about the move that the supplier might need to know',
            cancellation_reason: nil,
            cancellation_reason_comment: nil,
            created_at: move.created_at.iso8601,
            date: move.date.iso8601,
            date_from: move.date_from.iso8601,
            date_to: nil,
            move_agreed: nil,
            move_agreed_by: nil,
            move_type: 'court_appearance',
            reference: move.reference,
            rejection_reason: nil,
            status: 'requested',
            time_due: move.time_due.iso8601,
            updated_at: move.updated_at.iso8601,
            is_lockout: false,
            recall_date: move.recall_date.iso8601,
          },
          relationships: {
            profile: { data: { id: move.profile.id, type: 'profiles' } },
            from_location: { data: { id: move.from_location.id, type: 'locations' } },
            to_location: { data: { id: move.to_location.id, type: 'locations' } },
            prison_transfer_reason: { data: nil },
            court_hearings: { data: [] },
            allocation: { data: nil },
            original_move: { data: nil },
          },
        },
      }
    end

    it { expect(result).to include_json(expected_json) }
    it { expect(result[:included]).to be_nil }
  end

  context 'with all supported includes' do
    let(:move) do
      create(
        :move,
        :with_original_move,
        :with_court_hearings,
        :prison_transfer,
        profile: create(:profile, :with_documents),
        supplier: create(:supplier),
      )
    end

    let(:adapter_options) { { include: described_class::SUPPORTED_RELATIONSHIPS } }

    before { ActiveStorage::Current.url_options = { protocol: 'http', host: 'www.example.com', port: 80 } } # This is used in the serializer

    it 'contains all included relationships' do
      expect(result[:included].map { |r| r[:type] })
        .to match_array(%w[people ethnicities genders locations locations profiles moves documents prison_transfer_reasons court_hearings suppliers])
    end

    # TODO: Remove me when we're done with location suppliers - this is used to distinguish between them
    it 'contains the moves supplier' do
      expect(result[:included].any? { |r| r[:id] == move.supplier_id }).to eq(true)
    end
  end

  describe 'important_events' do
    let(:includes) { %i[important_events] }
    let(:adapter_options) { { include: includes, params: { included: includes } } }

    context 'with generic events' do
      let(:move) { create(:move) }
      let(:included_event) { result[:included].find { |include| include[:id] == event.id } }

      let(:expected_event_relationships) do
        [
          { id: event.id, type: 'events' },
        ]
      end

      let!(:event) { create(:event_person_move_assault, eventable: move) }

      it 'contains important_events relationship' do
        expect(result[:data][:relationships][:important_events]).to eq(data: expected_event_relationships)
      end

      it 'contains included events' do
        expect(included_event).to be_present
      end
    end

    context 'without generic events' do
      it 'contains an empty relationship' do
        expect(result[:data][:relationships][:important_events]).to eq(data: [])
      end

      it 'does not contain an included event' do
        expect(result[:included]).to be_blank
      end
    end
  end

  describe 'timeline_events' do
    let(:includes) { %i[timeline_events timeline_events.eventable timeline_events.to_location] }
    let(:adapter_options) { { include: includes, params: { included: includes } } }

    context 'with generic events' do
      let(:move) { create(:move) }
      let(:now) {  Time.zone.now }
      let(:included_event) { result[:included].find { |include| include[:id] == event.id } }

      let(:expected_event_relationships) do
        [
          { id: event.id, type: 'events' },
        ]
      end

      context 'when the event has no additional relationships' do
        let!(:event) { create(:event_move_cancel, eventable: move, occurred_at: now) }

        it 'contains timeline_events relationship' do
          expect(result[:data][:relationships][:timeline_events]).to eq(data: expected_event_relationships)
        end

        it 'contains included events' do
          expect(included_event).to be_present
        end

        it 'contains the correct relationships for the event include' do
          event_relationships = {
            eventable: { data: { id: event.eventable.id, type: 'moves' } },
            supplier: { data: { id: event.supplier.id, type: 'suppliers' } },
          }

          expect(included_event[:relationships]).to eq(event_relationships)
        end
      end

      context 'when the event has additional relationships' do
        let!(:event) { create(:event_move_redirect, eventable: move, occurred_at: now) }

        it 'contains timeline_events relationship' do
          expect(result[:data][:relationships][:timeline_events]).to eq(data: expected_event_relationships)
        end

        it 'contains included location' do
          expect(result[:included]).to include(hash_including(id: event.to_location.id, type: 'locations'))
        end

        it 'contains included events' do
          expect(included_event).to be_present
        end

        it 'contains the correct relationships for the event include' do
          event_relationships = {
            to_location: { data: { id: event.to_location.id, type: 'locations' } },
            eventable: { data: { id: event.eventable_id, type: 'moves' } },
            supplier: { data: { id: event.supplier.id, type: 'suppliers' } },
          }

          expect(included_event[:relationships]).to eq(event_relationships)
        end
      end
    end

    context 'without generic events' do
      it 'contains an empty relationship' do
        expect(result[:data][:relationships][:timeline_events]).to eq(data: [])
      end

      it 'does not contain an included event' do
        expect(result[:included]).to be_blank
      end
    end
  end
end
