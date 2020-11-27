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
            profile: { data: { id: move.profile_id, type: 'profiles' } },
            from_location: { data: { id: move.from_location_id, type: 'locations' } },
            to_location: { data: { id: move.to_location_id, type: 'locations' } },
            prison_transfer_reason: { data: { id: move.prison_transfer_reason_id, type: 'prison_transfer_reasons' } },
            supplier: { data: { id: move.supplier_id, type: 'suppliers' } },
            allocation: { data: nil },
          },
        },
      }
    end

    it { expect(result).to include_json(expected_json) }
    it { expect(result[:included]).to be_nil }
  end

  context 'with all supported includes' do
    let(:options) do
      {
        include: described_class::SUPPORTED_RELATIONSHIPS,
        params: { included: %i[person_escort_record flags] },
      }
    end

    let!(:person_escort_record) { create(:person_escort_record, move: move, profile: move.profile) }
    let!(:flag) { create(:framework_flag) }
    let!(:response) { create(:string_response, assessmentable: person_escort_record, framework_flags: [flag]) }

    it 'contains all included relationships' do
      expect(result[:included].map { |r| r[:type] })
        .to match_array(%w[people ethnicities genders locations locations profiles prison_transfer_reasons suppliers person_escort_records framework_flags])
    end
  end
end
