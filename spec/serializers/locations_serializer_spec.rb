# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationsSerializer do
  subject(:serializer) { described_class.new(location) }

  let(:created_at) { Time.zone.local(2018, 6, 1) }
  let(:disabled_at) { Time.zone.local(2019, 1, 1) }
  let(:location) { create :location, :with_address, :with_coordinates, created_at:, disabled_at: }
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

  it 'contains a premise attribute' do
    expect(attributes[:premise]).to eql location.premise
  end

  it 'contains a locality attribute' do
    expect(attributes[:locality]).to eql location.locality
  end

  it 'contains a city attribute' do
    expect(attributes[:city]).to eql location.city
  end

  it 'contains a country attribute' do
    expect(attributes[:country]).to eql location.country
  end

  it 'contains a postcode attribute' do
    expect(attributes[:postcode]).to eql location.postcode
  end

  it 'contains a latitude attribute' do
    expect(attributes[:latitude]).to eql location.latitude
  end

  it 'contains a longitude attribute' do
    expect(attributes[:longitude]).to eql location.longitude
  end

  it 'contains a nomis_agency_id attribute' do
    expect(attributes[:nomis_agency_id]).to eql 'PEI'
  end

  it 'contains a young_offender_institution attribute' do
    expect(attributes[:young_offender_institution]).to eql location.young_offender_institution
  end

  it 'contains a created_at attribute' do
    expect(attributes[:created_at]).to eql created_at.iso8601
  end

  it 'contains a disabled_at attribute' do
    expect(attributes[:disabled_at]).to eql disabled_at.iso8601
  end

  it 'contains an extradition_capable attribute' do
    expect(attributes[:extradition_capable]).to be nil
  end
end
