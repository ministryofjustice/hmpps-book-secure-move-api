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
    let(:expected_json) do
      [
        {
          id: move.profile.person_id,
          type: 'people',
          attributes: {
            first_names: move.profile.person.first_names,
            last_name: move.profile.person.last_name,
            date_of_birth: '1980-10-20',
            assessment_answers: [],
            identifiers: [
              { value: move.profile.person.police_national_computer, identifier_type: 'police_national_computer' },
              { value: move.profile.person.prison_number, identifier_type: 'prison_number' },
              { value: move.profile.person.criminal_records_office, identifier_type: 'criminal_records_office' },
            ],
            gender_additional_information: nil,
          },
        },
      ]

      it 'contains an included person' do
        expect(result[:included]).to(include_json(expected_json))
      end
    end
    let(:adapter_options) { { include: MoveSerializer::SUPPORTED_RELATIONSHIPS } }

    it 'contains a person' do
      expect(result_data[:relationships][:person]).to eq(data: { id: move.profile.person.id, type: 'people' })
    end

    it 'contains an included person' do
      expect(result[:included].map { |r| r[:type] }).to match_array(%w[people ethnicities genders locations locations profiles])
    end
  end

  describe 'person' do
    context 'with a person' do
      let(:adapter_options) { { include: MoveSerializer::SUPPORTED_RELATIONSHIPS, fields: MoveSerializer::INCLUDED_FIELDS } }
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
  end

  describe 'allocations' do
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

      it 'does not contain an included allocation' do
        expect(result[:included].map { |r| r[:type] }).to match_array(%w[locations locations ethnicities genders people profiles])
      end
    end
  end
end
