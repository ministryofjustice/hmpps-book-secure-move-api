# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrefillSourceSerializer do
  subject(:serializer) { described_class.new(person_escort_record) }

  let(:move) { create(:move) }
  let(:person_escort_record) { create(:person_escort_record, move: move, profile: move.profile) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

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
end
