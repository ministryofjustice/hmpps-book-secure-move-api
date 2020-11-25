# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::MovesSerializer do
  subject(:serializer) { described_class.new(move, options) }

  let(:move) { create :move, :prison_transfer }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  context 'with no options' do
    let(:options) { {} }
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
            move_type: 'prison_transfer',
            reference: move.reference,
            rejection_reason: nil,
            status: 'requested',
            time_due: move.time_due.iso8601,
            updated_at: move.updated_at.iso8601,
          },
          relationships: {
          },
        },
      }
    end

    it { expect(result).to include_json(expected_json) }
    it { expect(result[:included]).to be_nil }
  end

  context 'with included profile' do
    let(:options) { { params: { included: %i[profile] } } }

    it 'contains a `profile` relationship with profile' do
      expect(result[:data][:relationships][:profile][:data]).to eq({
        id: move.profile.id,
        type: 'profiles',
      })
    end
  end

  context 'with included from location' do
    let(:options) { { params: { included: %i[from_location] } } }

    it 'contains a `from_location` relationship with location' do
      expect(result[:data][:relationships][:from_location][:data]).to eq({
        id: move.from_location.id,
        type: 'locations',
      })
    end
  end

  context 'with included to location' do
    let(:options) { { params: { included: %i[to_location] } } }

    it 'contains a `to_location` relationship with location' do
      expect(result[:data][:relationships][:to_location][:data]).to eq({
        id: move.to_location.id,
        type: 'locations',
      })
    end
  end

  context 'with included prison transfer reason' do
    let(:options) { { params: { included: %i[prison_transfer_reason] } } }

    it 'contains a `prison_transfer_reason` relationship with prison transfer reason' do
      expect(result[:data][:relationships][:prison_transfer_reason][:data]).to eq({
        id: move.prison_transfer_reason.id,
        type: 'prison_transfer_reasons',
      })
    end
  end
end
