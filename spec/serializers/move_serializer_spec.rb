# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoveSerializer do
  subject(:serializer) { described_class.new(move) }

  let(:move) { create :move }
  let(:result) do
    JSON.parse(ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json).deep_symbolize_keys
  end
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }

  context 'with no options' do
    let(:adapter_options) { {} }

    it 'contains a type property' do
      expect(result_data[:type]).to eql 'moves'
    end

    it 'contains an id property' do
      expect(result_data[:id]).to eql move.id
    end

    it 'contains a status attribute' do
      expect(attributes[:status]).to eql move.status
    end

    it 'contains a move_type attribute' do
      expect(attributes[:move_type]).to eql move.move_type
    end

    it 'contains a nomis_event_id attribute' do
      expect(attributes[:nomis_event_id]).to eql move.nomis_event_id
    end

    it 'contains a rejection_reason attribute' do
      expect(attributes[:rejection_reason]).to eql move.rejection_reason
    end

    it 'contains a date attribute' do
      expect(attributes[:date]).to eql move.date.iso8601
    end

    it 'contains a time attribute' do
      expect(attributes[:time_due]).to eql move.time_due.iso8601
    end

    it 'contains an updated_at attribute' do
      expect(attributes[:updated_at]).to eql move.updated_at.iso8601
    end

    it 'contains an created_at attribute' do
      expect(attributes[:created_at]).to eql move.created_at.iso8601
    end

    it 'contains an additional_information attribute' do
      expect(attributes[:additional_information]).to eql move.additional_information
    end
  end

  context 'with main options' do
    let(:adapter_options) { { include: MoveSerializer::SUPPORTED_RELATIONSHIPS } }

    it 'contains a person' do
      expect(result_data[:relationships][:person]).to eq(data: { id: move.person.id, type: 'people' })
    end

    it 'contains an included person' do
      expect(result[:included].map { |r| r[:type] }).to match_array(%w[people ethnicities genders locations locations profiles])
    end
  end

  describe 'person' do
    context 'with a person' do
      # TODO: Remove support for person on a Move
      let(:adapter_options) { { include: 'person', fields: MoveSerializer::INCLUDED_FIELDS } }

      let(:expected_json) do
        person = move.person
        [
          {
            id: person.id,
            type: 'people',
            attributes: { first_names: person.first_names,
                          last_name: person.last_name,
                          date_of_birth: '1980-10-20' },
          },
        ]
      end

      it 'contains an included person' do
        expect(result[:included]).to(include_json(expected_json))
      end
    end

    context 'without a person' do
      let(:adapter_options) { { include: MoveSerializer::SUPPORTED_RELATIONSHIPS } }
      let(:move) { create(:move, profile: nil) }

      it 'contains an empty person' do
        expect(result_data[:relationships][:person]).to eq(data: nil)
      end

      it 'does not contain an included person' do
        expect(result[:included].map { |r| r[:type] }).to match_array(%w[locations locations])
      end
    end
  end

  describe 'locations' do
    let(:adapter_options) do
      {
        include: {
          from_location: %I[location_type title],
          to_location: %I[location_type title],
        },
      }
    end
    let(:expected_json) do
      [
        {
          id: move.from_location_id,
          type: 'locations',
          attributes: { location_type: 'prison', title: move.from_location.title },
        },
        {
          id: move.to_location_id,
          type: 'locations',
          attributes: { location_type: 'court', title: move.to_location.title },
        },
      ]
    end

    it 'contains an included from and to location' do
      expect(result[:included]).to(include_json(expected_json))
    end

    context 'without a to_location' do
      let(:adapter_options) do
        {
          include: {
            to_location: %I[location_type title],
          },
        }
      end
      let(:move) { create(:move, :prison_recall) }

      it 'contains empty location' do
        expect(result_data[:relationships][:to_location][:data]).to be_nil
      end

      it 'does not contain an included location' do
        expect(result[:included]).to be_nil
      end
    end
  end

  describe 'allocation' do
    context 'with an allocation' do
      let(:adapter_options) do
        { include: :allocation, fields: MoveSerializer::INCLUDED_FIELDS }
      end
      let(:move) { create(:move, :with_allocation) }
      let(:expected_json) do
        [
          {
            id: move.allocation.id,
            type: 'allocations',
            attributes: {
              moves_count: move.allocation.moves_count,
              created_at: move.allocation.created_at.iso8601,
            },
            relationships: {
              from_location: {
                data: {
                  id: move.from_location.id,
                  type: 'locations',
                },
              },
              to_location: {
                data: {
                  id: move.to_location.id,
                  type: 'locations',
                },
              },
            },
          },
        ]
      end

      it 'contains an allocation relationship' do
        expect(result_data[:relationships][:allocation]).to eq(data: { id: move.allocation.id, type: 'allocations' })
      end

      it 'contains an included allocation' do
        expect(result[:included]).to eq(expected_json)
      end
    end

    context 'without an allocation' do
      let(:adapter_options) { { include: MoveSerializer::SUPPORTED_RELATIONSHIPS } }

      it 'contains an empty allocation' do
        expect(result_data[:relationships][:allocation]).to eq(data: nil)
      end

      it 'does not contain an included move' do
        expect(result[:included].map { |r| r[:type] }).to match_array(%w[locations locations ethnicities genders people profiles])
      end
    end
  end

  describe 'original_move' do
    let(:adapter_options) { { include: MoveSerializer::SUPPORTED_RELATIONSHIPS } }

    context 'with an original_move' do
      let(:original_move) { create(:move) }
      let(:move) { create(:move, original_move: original_move) }

      it 'contains an original_move relationship' do
        expect(result_data[:relationships][:original_move]).to eq(data: { id: original_move.id, type: 'moves' })
      end

      it 'contains an included original_move' do
        expect(result[:included].map { |r| r[:type] }).to match_array(%w[locations locations ethnicities genders people profiles moves])
      end
    end

    context 'without an original_move' do
      it 'contains an empty original_move' do
        expect(result_data[:relationships][:allocation]).to eq(data: nil)
      end

      it 'does not contain an included move' do
        expect(result[:included].map { |r| r[:type] }).to match_array(%w[locations locations ethnicities genders people profiles])
      end
    end
  end

  describe 'prison_transfer_reason' do
    let(:adapter_options) do
      {
        include: {
          prison_transfer_reason: %I[title],
        },
      }
    end
    let(:move) { create(:move, :prison_transfer) }

    let(:expected_json) do
      [
        {
          id: move.prison_transfer_reason.id,
          type: 'prison_transfer_reasons',
          attributes: { title: move.prison_transfer_reason.title },
        },
      ]
    end

    it 'contains an included prison_transfer_reason' do
      expect(result[:included]).to(include_json(expected_json))
    end

    context 'without a prison_transfer_reason' do
      let(:move) { create(:move, prison_transfer_reason: nil) }

      it 'contains empty prison_transfer_reason' do
        expect(result_data[:relationships][:prison_transfer_reason][:data]).to be_nil
      end

      it 'does not contain an included prison_transfer_reason' do
        expect(result[:included]).to be_nil
      end
    end
  end

  describe 'documents' do
    let(:adapter_options) { { include: ['profile.documents'] } }
    let(:move) { create(:move, profile: create(:profile, :with_documents)) }

    before { ActiveStorage::Current.host = 'http://www.example.com' } # This is used in the serializer

    it 'contains included documents relationships' do
      expect(result[:included].map { |r| r[:type] })
        .to match_array(%w[profiles documents])
    end
  end
end
