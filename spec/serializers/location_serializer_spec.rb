# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationSerializer do
  subject(:serializer) { described_class.new(location) }

  let(:disabled_at) { Time.new(2019, 1, 1) }
  let(:supplier) { create(:supplier) }
  let(:location) { create :location, disabled_at: disabled_at, suppliers: [supplier] }
  let(:result) { JSON.parse(ActiveModelSerializers::Adapter.create(serializer).to_json).deep_symbolize_keys }
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
    expect(attributes[:key]).to eql 'hmp_pentonville'
  end

  it 'contains a title attribute' do
    expect(attributes[:title]).to eql 'HMP Pentonville'
  end

  it 'contains a nomis_agency_id attribute' do
    expect(attributes[:nomis_agency_id]).to eql 'PEI'
  end

  it 'contains a disabled_at attribute' do
    expect(Time.parse(attributes[:disabled_at])).to eql disabled_at
  end

  it 'contains a suppliers attribute' do
    expect(attributes[:suppliers]).not_to be_nil
  end
end
