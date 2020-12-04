# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrefillSourceSerializer do
  subject(:serializer) { described_class.new(assessment) }

  let(:assessment) { create(:person_escort_record) }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(assessment.id)
  end

  it 'contains a `status` attribute' do
    expect(result[:data][:attributes][:status]).to eq('not_started')
  end

  it 'contains a `confirmed_at` attribute' do
    expect(result[:data][:attributes][:confirmed_at]).to eq(assessment.confirmed_at)
  end

  it 'contains a `created_at` attribute' do
    expect(result[:data][:attributes][:created_at]).to eq(assessment.created_at.iso8601)
  end

  it 'contains a `nomis_sync_status` attribute' do
    expect(result[:data][:attributes][:nomis_sync_status]).to eq(assessment.nomis_sync_status)
  end
end
