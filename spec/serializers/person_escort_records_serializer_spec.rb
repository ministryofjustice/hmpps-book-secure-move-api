# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonEscortRecordsSerializer do
  subject(:serializer) { described_class.new(person_escort_record, options) }

  let(:person_escort_record) { create(:person_escort_record) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:options) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('person_escort_records')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(person_escort_record.id)
  end

  it 'contains a `status` attribute' do
    expect(result[:data][:attributes][:status]).to eq('not_started')
  end

  it 'contains a `confirmed_at` attribute' do
    expect(result[:data][:attributes][:confirmed_at]).to eq(person_escort_record.confirmed_at)
  end

  it 'contains a `created_at` attribute' do
    expect(result[:data][:attributes][:created_at]).to eq(person_escort_record.created_at.iso8601)
  end

  it 'contains a `nomis_sync_status` attribute' do
    expect(result[:data][:attributes][:nomis_sync_status]).to eq(person_escort_record.nomis_sync_status)
  end

  it 'omits `flags` relationship if not explicitly included' do
    expect(result[:data][:relationships]).not_to include(:flags)
  end

  context 'with included flags' do
    let(:options) { { params: { included: %i[flags] } } }

    it 'contains an empty `flags` relationship if no flags present' do
      expect(result[:data][:relationships][:flags][:data]).to be_empty
    end

    it 'contains a `flags` relationship with framework response flags' do
      flag = create(:framework_flag)
      create(:string_response, assessmentable: person_escort_record, framework_flags: [flag])

      expect(result[:data][:relationships][:flags][:data]).to contain_exactly(
        id: flag.id,
        type: 'framework_flags',
      )
    end
  end
end
