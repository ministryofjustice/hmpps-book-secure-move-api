# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FrameworkNomisMappingSerializer do
  subject(:serializer) { described_class.new(framework_nomis_mapping) }

  let(:framework_nomis_mapping) { create(:framework_nomis_mapping) }
  let!(:framework_response) do
    create(:string_response, framework_nomis_mappings: [framework_nomis_mapping])
  end
  let(:result) { ActiveModelSerializers::Adapter.create(serializer, include: includes).serializable_hash }
  let(:includes) { {} }

  it 'contains a `type` property' do
    expect(result[:data][:type]).to eq('framework_nomis_mappings')
  end

  it 'contains an `id` property' do
    expect(result[:data][:id]).to eq(framework_nomis_mapping.id)
  end

  it 'contains a `code` attribute' do
    expect(result[:data][:attributes][:code]).to eq(framework_nomis_mapping.code)
  end

  it 'contains a `code_type` attribute' do
    expect(result[:data][:attributes][:code_type]).to eq(framework_nomis_mapping.code_type)
  end

  it 'contains a `code_description` attribute' do
    expect(result[:data][:attributes][:code_description]).to eq(framework_nomis_mapping.code_description)
  end

  it 'contains a `comments` attribute' do
    expect(result[:data][:attributes][:comments]).to eq(framework_nomis_mapping.comments)
  end

  it 'contains a `start_date` attribute' do
    expect(result[:data][:attributes][:start_date]).to eq(framework_nomis_mapping.start_date)
  end

  it 'contains a `end_date` attribute' do
    expect(result[:data][:attributes][:end_date]).to eq(framework_nomis_mapping.end_date)
  end

  it 'contains a `creation_date` attribute' do
    expect(result[:data][:attributes][:creation_date]).to eq(framework_nomis_mapping.creation_date)
  end

  it 'contains a `expiry_date` attribute' do
    expect(result[:data][:attributes][:expiry_date]).to eq(framework_nomis_mapping.expiry_date)
  end
end
