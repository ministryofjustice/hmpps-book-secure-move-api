# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationSerializer do
  subject(:serializer) { described_class.new(location, include: %i[suppliers]) }

  let(:disabled_at) { Time.zone.local(2019, 1, 1) }
  let(:supplier) { create(:supplier) }
  let(:location) { create :location, disabled_at: disabled_at, suppliers: [supplier] }
  let(:result) { JSON.parse(serializer.serializable_hash.to_json).deep_symbolize_keys }
  let(:result_data) { result[:data] }
  let(:attributes) { result_data[:attributes] }

  it 'contains a type property' do
    expect(result_data[:type]).to eql 'locations'
  end

  it 'contains an id property' do
    expect(result_data[:id]).to eql location.id
  end

  it 'has a can_upload_documents property' do
    expect(attributes[:can_upload_documents]).to eql location.can_upload_documents
  end

  it 'contains a location_type attribute' do
    expect(attributes[:location_type]).to eql 'prison'
  end

  it 'contains a key attribute' do
    expect(attributes[:key]).to eql location.key
  end

  it 'contains a title attribute' do
    expect(attributes[:title]).to eql location.title
  end

  it 'contains a nomis_agency_id attribute' do
    expect(attributes[:nomis_agency_id]).to eql 'PEI'
  end

  it 'contains a disabled_at attribute' do
    expect(attributes[:disabled_at]).to eql disabled_at.iso8601
  end

  it 'contains an included supplier' do
    expect(result[:included].map { |r| r[:type] }).to match_array(%w[suppliers])
  end
end
