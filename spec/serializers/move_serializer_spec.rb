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
    let(:adapter_options) { { include: MoveSerializer::INCLUDED_ATTRIBUTES } }

    it 'contains a person' do
      expect(result_data[:relationships][:person]).to eq(data: { id: move.person.id, type: 'people' })
    end

    it 'contains an included person' do
      expect(result[:included].map { |r| r[:type] }).to match_array(%w[people ethnicities genders locations locations])
    end
  end

  describe 'person' do
    context 'with a person' do
      let(:adapter_options) { { include: { person: %I[first_names last_name] } } }
      let(:expected_json) do
        [
          {
            id: move.person_id,
            type: 'people',
            attributes: { first_names: move.person.latest_profile.first_names,
                          last_name: move.person.latest_profile.last_name, date_of_birth: '1980-10-20' },
          },
        ]
      end

      it 'contains an included person' do
        expect(result[:included]).to(include_json(expected_json))
      end
    end

    context 'without a person' do
      let(:adapter_options) { { include: MoveSerializer::INCLUDED_ATTRIBUTES } }
      let(:move) { create(:move, person: nil) }

      it 'does not contain a person' do
        expect(result_data[:relationships][:person]).to be_nil
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
end
