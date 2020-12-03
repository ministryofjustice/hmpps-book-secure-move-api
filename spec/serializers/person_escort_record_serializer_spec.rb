# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecordSerializer do
  subject(:serializer) { described_class.new(person_escort_record, include: includes) }

  let(:move) { create(:move) }
  let(:person_escort_record) { create(:person_escort_record, move: move, profile: move.profile) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('person_escort_records')
  end

  it 'contains a `profile` relationship' do
    expect(result[:data][:relationships][:profile][:data]).to eq(
      id: person_escort_record.profile.id,
      type: 'profiles',
    )
  end

  it 'contains a `move` relationship' do
    expect(result[:data][:relationships][:move][:data]).to eq(
      id: person_escort_record.move.id,
      type: 'moves',
    )
  end

  it 'contains a nil `prefill_source` relationship if no prefill_source present' do
    expect(result[:data][:relationships][:prefill_source][:data]).to be_nil
  end

  context 'with a prefill source' do
    let(:person_escort_record) { create(:person_escort_record, :prefilled) }

    it 'contains a`prefill_source` relationship ' do
      expect(result[:data][:relationships][:prefill_source][:data]).to eq(
        id: person_escort_record.prefill_source.id,
        type: 'person_escort_records',
      )
    end
  end

  context 'with include options' do
    let(:includes) { %w[prefill_source] }
    let(:person_escort_record) do
      create(:person_escort_record, :prefilled)
    end

    let(:expected_json) do
      UnorderedArray(
        {
          id: person_escort_record.prefill_source.id,
          type: 'person_escort_records',
          attributes: { created_at: person_escort_record.prefill_source.created_at.iso8601 },
        },
      )
    end

    it 'contains an included responses and question' do
      expect(result[:included]).to include_json(expected_json)
    end
  end
end
